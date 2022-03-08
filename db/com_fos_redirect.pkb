create or replace package body com_fos_redirect
as

--------------------------------------------------------------------------------
-- Return the URL derived from static text or a plsql expression with optional
-- choice to prepare the URL
--------------------------------------------------------------------------------
function get_url
  ( p_dynamic_action apex_plugin.t_dynamic_action
  , p_triggering_element varchar2 default 'document'
  ) return varchar2
as
    l_url_source      p_dynamic_action.attribute_01%type := nvl(p_dynamic_action.attribute_01, 'static');
    l_url             p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;
    l_plsql_expr      p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;
    l_prepare_url     boolean                            := nvl(p_dynamic_action.attribute_09, 'Y') = 'Y';
begin

    if l_url_source = 'plsql-expression'
    then
        l_url := apex_plugin_util.get_plsql_expression_result(l_plsql_expr);
    else
        l_url := apex_plugin_util.replace_substitutions(l_url);
    end if;
    --
    -- We will replace again in the case that our plsql expression returned a url
    -- with substitutions or our static replacement returned a url with substitutions e.g. &HOME_LINK.
    --
    if regexp_instr(l_url, '\&[^[:blank:]]*?\.') > 0
    then
        l_url := apex_plugin_util.replace_substitutions(l_url);
    end if;

    if l_prepare_url
    then
        l_url := apex_util.prepare_url
                    ( p_url                => l_url
                    , p_checksum_type      => 'SESSION'
                    , p_triggering_element => p_triggering_element -- thanks Alan Arentsen Jul-2021
                    );
    end if;

    return l_url;

end get_url;

--------------------------------------------------------------------------------
-- Main plug-in render function
--------------------------------------------------------------------------------
function render
  ( p_dynamic_action apex_plugin.t_dynamic_action
  , p_plugin         apex_plugin.t_plugin
  )
return apex_plugin.t_dynamic_action_render_result
as
    l_result apex_plugin.t_dynamic_action_render_result;

    --general attributes
    l_ajax_identifier      varchar2(4000)                     := apex_plugin.get_ajax_identifier;
    l_context              p_dynamic_action.attribute_07%type := nvl(p_dynamic_action.attribute_07, 'window');
    l_new_window           boolean                            := nvl(p_dynamic_action.attribute_08,'N') = 'Y';
    l_exec_plsql           boolean                            := instr(p_dynamic_action.attribute_04, 'execute-plsql') > 0;

    -- spinner settings
    l_show_spinner         boolean                            := nvl(p_dynamic_action.attribute_10, 'N') = 'Y';

    -- page items to submit settings
    l_items_to_submit      varchar2(4000)                     := apex_plugin_util.page_item_names_to_jquery(p_dynamic_action.attribute_06);

    -- Javascript Initialization Code
    l_init_js_fn           varchar2(32767)                    := nvl(apex_plugin_util.replace_substitutions(p_dynamic_action.init_javascript_code), 'undefined');

begin
    if apex_application.g_debug and substr(:DEBUG,6) >= 6
    then
        apex_plugin_util.debug_dynamic_action
          ( p_dynamic_action => p_dynamic_action
          , p_plugin         => p_plugin
          );
    end if;

    -- create a json object holding the dynamic action settings
    apex_json.initialize_clob_output;
    apex_json.open_object;
    apex_json.write('ajaxIdentifier'     , l_ajax_identifier        );
    apex_json.write('status'             , 'success'                );

    apex_json.write('url'                , get_url(p_dynamic_action));
    apex_json.write('context'            , l_context                );
    apex_json.write('newWindow'          , l_new_window             );
    apex_json.write('itemsToSubmit'      , l_items_to_submit        );
    apex_json.write('executePlsql'       , l_exec_plsql             );

    apex_json.open_object('spinnerSettings');
    apex_json.write('showSpinner'        , l_show_spinner           );
    apex_json.write('showSpinnerOverlay' , TRUE                     );
    apex_json.write('showSpinnerOnRegion', FALSE                    );
    apex_json.close_object;

    -- close JSON settings
    apex_json.close_object;

    -- initialization code for the region widget. needed to handle the refresh event
    l_result.javascript_function := 'function() { FOS.utils.navigation(this, ' || apex_json.get_clob_output|| ', '|| l_init_js_fn || '); }';

    apex_json.free_output;
    return l_result;
end render;

--------------------------------------------------------------------------------
-- called when region should be refreshed and returns the static content.
-- additionally it is possible to run some plsql code before the static content
-- is evaluated
--------------------------------------------------------------------------------
function ajax
  ( p_dynamic_action apex_plugin.t_dynamic_action
  , p_plugin         apex_plugin.t_plugin
  )
return apex_plugin.t_dynamic_action_ajax_result
as
    -- plug-in attributes
    l_exec_plsql           boolean                            := instr(p_dynamic_action.attribute_04, 'execute-plsql') > 0;
    l_exec_plsql_code      p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_05;
    l_context              p_dynamic_action.attribute_07%type := nvl(p_dynamic_action.attribute_07, 'window');
    l_new_window           boolean                            := nvl(p_dynamic_action.attribute_08,'N') = 'Y';
    l_item_names           apex_t_varchar2;

    --ajax parameters
    l_triggering_element   varchar2(32767) := nvl(apex_application.g_x01, 'document');

    -- resulting content
    l_content              clob                       := '';

    l_return               apex_plugin.t_dynamic_action_ajax_result;
begin
    -- standard debugging intro, but only if necessary
    if apex_application.g_debug and substr(:DEBUG,6) >= 6
    then
        apex_plugin_util.debug_dynamic_action
          ( p_plugin         => p_plugin
          , p_dynamic_action => p_dynamic_action
          );
    end if;

    -- if required, execute plsql to perform some page item calculations
    if l_exec_plsql
    then
        apex_exec.execute_plsql(p_plsql_code => l_exec_plsql_code);
    end if;

    -- return our JSON response with an updated URL
    apex_json.open_object;
    apex_json.write('status'   , 'success'                );
    apex_json.write('url'      , get_url(p_dynamic_action, l_triggering_element));
    apex_json.write('context'  , l_context                );
    apex_json.write('newWindow', l_new_window             );
    apex_json.close_object;

    return l_return;
end ajax;

end;
/


