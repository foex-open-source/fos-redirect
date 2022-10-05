prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.10.04'
,p_release=>'19.2.0.00.18'
,p_default_workspace_id=>1620873114056663
,p_default_application_id=>102
,p_default_id_offset=>0
,p_default_owner=>'FOS_MASTER_WS'
);
end;
/

prompt APPLICATION 102 - FOS Dev - Plugin Master
--
-- Application Export:
--   Application:     102
--   Name:            FOS Dev - Plugin Master
--   Exported By:     FOS_MASTER_WS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 61118001090994374
--     PLUGIN: 134108205512926532
--     PLUGIN: 1039471776506160903
--     PLUGIN: 547902228942303344
--     PLUGIN: 217651153971039957
--     PLUGIN: 412155278231616931
--     PLUGIN: 1389837954374630576
--     PLUGIN: 461352325906078083
--     PLUGIN: 13235263798301758
--     PLUGIN: 216426771609128043
--     PLUGIN: 37441962356114799
--     PLUGIN: 1846579882179407086
--     PLUGIN: 8354320589762683
--     PLUGIN: 50031193176975232
--     PLUGIN: 106296184223956059
--     PLUGIN: 35822631205839510
--     PLUGIN: 2674568769566617
--     PLUGIN: 183507938916453268
--     PLUGIN: 14934236679644451
--     PLUGIN: 2600618193722136
--     PLUGIN: 2657630155025963
--     PLUGIN: 284978227819945411
--     PLUGIN: 56714461465893111
--     PLUGIN: 98648032013264649
--     PLUGIN: 455014954654760331
--     PLUGIN: 98504124924145200
--     PLUGIN: 212503470416800524
--   Manifest End
--   Version:         19.2.0.00.18
--   Instance ID:     250144500186934
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_fos_redirect
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(2674568769566617)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.FOS.REDIRECT'
,p_display_name=>'FOS - Redirect'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>'#PLUGIN_FILES#js/script#MIN#.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- triggering element related data',
'type t_triggering_element is record ',
'    ( when_selection_type_code varchar2(1000)',
'    , when_region_id           varchar2(1000)',
'    , when_button_id           varchar2(1000)',
'    , when_element             varchar2(1000)',
'    , region_static_id         varchar2(1000)',
'    , button_static_id         varchar2(1000) ',
');',
'--------------------------------------------------------------------------------',
'-- Return the URL derived from static text or a plsql expression with optional',
'-- choice to prepare the URL',
'--------------------------------------------------------------------------------',
'function get_url',
'  ( p_dynamic_action apex_plugin.t_dynamic_action',
'  , p_triggering_element varchar2 default ''document''  ',
'  ) return varchar2',
'as',
'    l_url_source      p_dynamic_action.attribute_01%type := nvl(p_dynamic_action.attribute_01, ''static'');',
'    l_url             p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'    l_plsql_expr      p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'    l_prepare_url     boolean                            := nvl(p_dynamic_action.attribute_09, ''Y'') = ''Y'';',
'begin',
'',
'    if l_url_source = ''plsql-expression'' ',
'    then',
'        l_url := apex_plugin_util.get_plsql_expression_result(l_plsql_expr);',
'    else',
'        l_url := apex_plugin_util.replace_substitutions(l_url);',
'    end if;',
'    --',
'    -- We will replace again in the case that our plsql expression returned a url',
'    -- with substitutions or our static replacement returned a url with substitutions e.g. &HOME_LINK.',
'    --',
'    if regexp_instr(l_url, ''\&[^[:blank:]]*?\.'') > 0 ',
'    then',
'        l_url := apex_plugin_util.replace_substitutions(l_url);',
'    end if;',
'    ',
'    if l_prepare_url ',
'    then',
'        l_url := apex_util.prepare_url',
'                    ( p_url                => l_url',
'                    , p_checksum_type      => ''SESSION''',
'                    , p_triggering_element => p_triggering_element -- thanks Alan Arentsen Jul-2021',
'                    );',
'    end if;',
'    ',
'    return l_url;',
'    ',
'end get_url;',
'',
'--------------------------------------------------------------------------------',
'-- Main plug-in render function',
'--------------------------------------------------------------------------------',
'function render',
'  ( p_dynamic_action apex_plugin.t_dynamic_action',
'  , p_plugin         apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_dynamic_action_render_result',
'as',
'    l_result apex_plugin.t_dynamic_action_render_result;',
'',
'    --general attributes',
'    l_ajax_identifier          varchar2(4000)                     := apex_plugin.get_ajax_identifier;',
'    l_context                  p_dynamic_action.attribute_07%type := nvl(p_dynamic_action.attribute_07, ''window'');',
'    l_new_window               boolean                            := nvl(p_dynamic_action.attribute_08,''N'') = ''Y'';',
'    l_exec_plsql               boolean                            := instr(p_dynamic_action.attribute_04, ''execute-plsql'') > 0;',
'    ',
'    -- spinner settings',
'    l_show_spinner             boolean                            := nvl(p_dynamic_action.attribute_10, ''N'') = ''Y'';',
'        ',
'    -- page items to submit settings',
'    l_items_to_submit          varchar2(4000)                     := apex_plugin_util.page_item_names_to_jquery(p_dynamic_action.attribute_06);',
'',
'    -- Javascript Initialization Code',
'    l_init_js_fn               varchar2(32767)                    := nvl(apex_plugin_util.replace_substitutions(p_dynamic_action.init_javascript_code), ''undefined'');',
'    ',
'    -- triggering element attributes',
'    l_triggering_element_data  t_triggering_element;',
'    l_triggering_element       varchar2(1000);',
'    l_triggering_element_expr  varchar2(32767);',
'    c_triggering_element       varchar(100)                       := ''#TRIGGERING_ELEMENT#'';',
'    ',
'begin',
'    if apex_application.g_debug and substr(:DEBUG,6) >= 6 ',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_dynamic_action => p_dynamic_action',
'          , p_plugin         => p_plugin',
'          );',
'    end if;',
'    ',
'    -- get the triggering element',
'    begin',
'        select d.when_selection_type_code',
'             , d.when_region_id',
'             , d.when_button_id',
'             , d.when_element',
'             , r.static_id        as region_static_id',
'             , b.button_static_id as button_static_id',
'          into l_triggering_element_data',
'          from apex_application_page_da        d',
'     left join apex_application_page_da_acts   a ',
'            on d.dynamic_action_id = a.dynamic_action_id',
'     left join apex_application_page_buttons   b',
'            on b.button_id = d.when_button_id',
'     left join apex_application_page_regions   r',
'            on r.region_id = d.when_region_id',
'         where d.application_id     = :APP_ID',
'           and d.page_id            = :APP_PAGE_ID',
'           and a.action_id          = p_dynamic_action.id',
'      group by d.when_selection_type_code',
'             , d.when_region_id',
'             , d.when_button_id',
'             , d.when_element',
'             , r.static_id',
'             , b.button_static_id',
'    ;',
'    exception',
'        when others then',
'            null;',
'    end;',
'    ',
'    l_triggering_element := case l_triggering_element_data.when_selection_type_code',
'                                when ''BUTTON'' then',
'                                      case ',
'                                          when l_triggering_element_data.button_static_id is null then',
'                                              ''B'' || l_triggering_element_data.when_button_id',
'                                          else',
'                                              l_triggering_element_data.button_static_id',
'                                       end',
'                                when ''REGION'' then',
'                                    case ',
'                                        when l_triggering_element_data.region_static_id is null then',
'                                            ''R'' || l_triggering_element_data.when_region_id',
'                                        else',
'                                            l_triggering_element_data.region_static_id',
'                                       end',
'                                when ''ITEM'' then',
'                                    l_triggering_element_data.when_element',
'                                when ''JQUERY_SELECTOR'' then',
'                                    ''"''|| l_triggering_element_data.when_element || ''"''',
'                                else ',
'                                    case',
'                                        when l_triggering_element_data.when_element is not null then',
'                                            c_triggering_element',
'                                        else',
'                                            ''document''',
'                                   end',
'                           end;',
'    ',
'    -- create a json object holding the dynamic action settings',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'    apex_json.write(''ajaxIdentifier''      , l_ajax_identifier        );',
'    apex_json.write(''status''              , ''success''                );',
'',
'    apex_json.write(''url''                 , get_url(p_dynamic_action,l_triggering_element));',
'    ',
'    if l_triggering_element = c_triggering_element',
'    then',
'        apex_json.write_raw',
'            ( p_name  =>''triggeringElementExpr''',
'            , p_value => ''function(){ return ('' || l_triggering_element_data.when_element || '');}''',
'            );',
'    end if;',
'    apex_json.write(''context''             , l_context                );',
'    apex_json.write(''newWindow''           , l_new_window             );',
'    apex_json.write(''itemsToSubmit''       , l_items_to_submit        );',
'    apex_json.write(''executePlsql''        , l_exec_plsql             );',
'    ',
'    apex_json.open_object(''spinnerSettings'');',
'    apex_json.write(''showSpinner''         , l_show_spinner           );',
'    apex_json.write(''showSpinnerOverlay''  , TRUE                     );',
'    apex_json.write(''showSpinnerOnRegion'' , FALSE                    );',
'    apex_json.close_object;',
'',
'    -- close JSON settings',
'    apex_json.close_object;',
'',
'    -- initialization code for the region widget. needed to handle the refresh event',
'    l_result.javascript_function := ''function() { FOS.utils.navigation(this, '' || apex_json.get_clob_output|| '', ''|| l_init_js_fn || ''); }'';',
'    ',
'    apex_json.free_output;',
'    return l_result;',
'end render;',
'',
'--------------------------------------------------------------------------------',
'-- called when region should be refreshed and returns the static content.',
'-- additionally it is possible to run some plsql code before the static content ',
'-- is evaluated',
'--------------------------------------------------------------------------------',
'function ajax',
'  ( p_dynamic_action apex_plugin.t_dynamic_action',
'  , p_plugin         apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_dynamic_action_ajax_result',
'as',
'    -- plug-in attributes',
'    l_exec_plsql           boolean                            := instr(p_dynamic_action.attribute_04, ''execute-plsql'') > 0;',
'    l_exec_plsql_code      p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_05;',
'    l_context              p_dynamic_action.attribute_07%type := nvl(p_dynamic_action.attribute_07, ''window'');',
'    l_new_window           boolean                            := nvl(p_dynamic_action.attribute_08,''N'') = ''Y'';',
'    l_item_names           apex_t_varchar2;',
'    ',
'    --ajax parameters',
'    l_triggering_element   varchar2(32767) := nvl(apex_application.g_x01, ''document'');',
'    ',
'    -- resulting content',
'    l_content              clob                       := '''';',
'',
'    l_return               apex_plugin.t_dynamic_action_ajax_result;',
'begin',
'    -- standard debugging intro, but only if necessary',
'    if apex_application.g_debug and substr(:DEBUG,6) >= 6',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action',
'          );',
'    end if;',
'    ',
'    -- if required, execute plsql to perform some page item calculations',
'    if l_exec_plsql ',
'    then',
'        apex_exec.execute_plsql(p_plsql_code => l_exec_plsql_code);',
'    end if;',
'',
'    -- return our JSON response with an updated URL',
'    apex_json.open_object;',
'    apex_json.write(''status''   , ''success''                );',
'    apex_json.write(''url''      , get_url(p_dynamic_action, l_triggering_element));',
'    apex_json.write(''context''  , l_context                );',
'    apex_json.write(''newWindow'', l_new_window             );',
'    apex_json.close_object;                                                                          ',
'',
'    return l_return;',
'end ajax;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'WAIT_FOR_RESULT'
,p_substitute_attributes=>false
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The <strong>FOS - Redirect</strong> dynamic action plug-in is an easy and declarative way to redirect to another page, URL, or open a modal dialog.</p>',
'<p>You have the ability to redirect to a static URL (with substitutions) or a URL that is returned from a PL/SQL Expression.</p>',
'<p>Additionally you can submit page items and update their session state prior to the URL redirect and optionally execute some PL/SQL Code. The URL will be recomputed on the server when doing this. If you are using session state protection it will re'
||'turn the URL with updated checksums.</p>'))
,p_version_identifier=>'22.1.0'
,p_about_url=>'https://fos.world'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'@fos-auto-return-to-page',
'@fos-auto-open-files:js/script.js'))
,p_files_version=>114
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(58073157246273209)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'URL Source'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'static'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>Define how the url is obtained e.g. either by "Static Text" or from a "PL/SQL Expression"</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(58073681178275644)
,p_plugin_attribute_id=>wwv_flow_api.id(58073157246273209)
,p_display_sequence=>10
,p_display_value=>'Static'
,p_return_value=>'static'
,p_help_text=>'<p>The URL will be defined using static text with page item substitution support.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(58074073188276966)
,p_plugin_attribute_id=>wwv_flow_api.id(58073157246273209)
,p_display_sequence=>20
,p_display_value=>'PL/SQL Expression'
,p_return_value=>'plsql-expression'
,p_help_text=>'<p>The URL will be defined from a PL/SQL expression with page item substitution support within the expression itself and on the result.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(2674755418566634)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Target Page/URL'
,p_attribute_type=>'LINK'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(58073157246273209)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'static'
,p_help_text=>'<p>The link to the target page or URL.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(58074620387285904)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'URL PL/SQL Expression'
,p_attribute_type=>'PLSQL EXPRESSION'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(58073157246273209)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'plsql-expression'
,p_help_text=>'<p>Enter a PL/SQL expression that will return your URL e.g.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(58074988798291393)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Options'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>Choose from the available options:</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(58075381131309291)
,p_plugin_attribute_id=>wwv_flow_api.id(58074988798291393)
,p_display_sequence=>10
,p_display_value=>'Submit Page Items Before Redirect'
,p_return_value=>'update-session-state'
,p_help_text=>'<p>You can submit any items on the page before performing the redirect. If any of the page items are used in the URL as substitutions, the URL will be updated and (optionally) prepare_url will be called.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(58075776992313263)
,p_plugin_attribute_id=>wwv_flow_api.id(58074988798291393)
,p_display_sequence=>20
,p_display_value=>'Execute PL/SQL Before Redirect'
,p_return_value=>'execute-plsql'
,p_help_text=>'<p>You can choose to submit any items on the page and execute some PL/SQL logic before performing the redirect. If any of the page items are used in the URL as substitutions, the URL will be updated and (optionally) prepare_url will be called.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(58076753670341881)
,p_plugin_attribute_id=>wwv_flow_api.id(58074988798291393)
,p_display_sequence=>30
,p_display_value=>'[for Modal Dialogs] Redirect Parent Page'
,p_return_value=>'redirect-parent'
,p_help_text=>'<p>Check this option when you are using this action on a modal dialog page and you want to redirect the main page, and not redirect the page open in the dialog.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(58076109914324218)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Execute PL/SQL'
,p_attribute_type=>'PLSQL'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(58074988798291393)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'execute-plsql'
,p_help_text=>'<p>Enter the PL/SQL code you would like to execute before the redirect occurs.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(58076467026327837)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Page Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(58074988798291393)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'update-session-state,execute-plsql'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Enter the uppercase page items submitted to the server, and therefore, available for use within your <strong>PL/SQL Code</strong>.</p>',
'<p>You can type in the item name or pick from the list of available items.',
'If you pick from the list and there is already text entered then a comma is placed at the end of the existing text, followed by the item name returned from the list.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(58077259426381019)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Document Context'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'parent'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(58074988798291393)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'redirect-parent'
,p_lov_type=>'STATIC'
,p_help_text=>'<p>This setting only applies for (Non Modal/Modal) Dialogs. You can choose to redirect the <strong>parent</strong> page (the page that opened the dialog) or the <strong>top</strong> level document if you have multiple dialogs open. <strong>Note:</str'
||'ong> It''s most likely that top = parent in the majority of cases.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(58077744861381948)
,p_plugin_attribute_id=>wwv_flow_api.id(58077259426381019)
,p_display_sequence=>10
,p_display_value=>'Parent Page'
,p_return_value=>'parent'
,p_help_text=>'<p>You can choose to redirect the <strong>parent</strong> page i.e. the one that opened the dialog.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(58078152214382792)
,p_plugin_attribute_id=>wwv_flow_api.id(58077259426381019)
,p_display_sequence=>20
,p_display_value=>'Top Page'
,p_return_value=>'top'
,p_help_text=>'<p>You can choose to redirect the <strong>top</strong> level document i.e. if you have multiple dialogs open.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(58078750721392452)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Open Target in New Window'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(58074988798291393)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_IN_LIST'
,p_depending_on_expression=>'redirect-parent'
,p_help_text=>'<p>Choose this option when you want the URL to be opened in a new browser window/tab depending upon the default behaviour of the browser.</p> '
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(60219192441184159)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>35
,p_prompt=>'Prepare URL'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Enable this option to call APEX_UTIL.PREPARE_URL, which will append checksums to the URL or transform the URL into a Javascript dialog.open call if you are redirecting to a Dialog page.</p>',
'<p>You would most likely disable this option in the circumstance that APEX_UTIL.PREPARE_URL has already been called in your PL/SQL expression that returns the URL.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(60224642949364100)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>65
,p_prompt=>'Show Spinner'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(58074988798291393)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'execute-plsql'
,p_help_text=>'<p>Enable/toggle this option to show a spinner when you are executing PLSQL prior to performing the page redirect.</p>'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(70756840937181597)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_name=>'fos-url-redirect-error'
,p_display_name=>'FOS - Redirect - Error'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A20676C6F62616C732061706578202A2F0A0A76617220464F53203D2077696E646F772E464F53207C7C207B7D3B0A464F532E7574696C73203D2077696E646F772E464F532E7574696C73207C7C207B7D3B0A0A2F2A2A0A202A20546869732066756E';
wwv_flow_api.g_varchar2_table(2) := '6374696F6E206576616C75617465732074686520676976656E20706172616D657465727320287468652075726C2072656469726563742920616E642073746F7073207468652063757272656E742064796E616D696320616374696F6E730A202A20696620';
wwv_flow_api.g_varchar2_table(3) := '74686520636F6E646974696F6E2064656D616E647320736F2E0A202A0A202A2040706172616D207B6F626A6563747D2020206461436F6E746578742020202020202020202020202020202020202020202044796E616D696320416374696F6E20636F6E74';
wwv_flow_api.g_varchar2_table(4) := '6578742061732070617373656420696E20627920415045580A202A2040706172616D207B6F626A6563747D202020636F6E66696720202020202020202020202020202020202020202020202020436F6E66696775726174696F6E206F626A65637420686F';
wwv_flow_api.g_varchar2_table(5) := '6C64696E67207468652075726C20726564697265637420636F6E66696775726174696F6E0A202A2040706172616D207B737472696E677D202020636F6E6669672E636F6E74657874202020202020202020202020202020202057686963682077696E646F';
wwv_flow_api.g_varchar2_table(6) := '7720636F6E74657874206973206265696E67207265646972656374656420652E672E205B77696E646F772C706172656E742C746F705D0A202A2040706172616D207B737472696E677D202020636F6E6669672E75726C2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(7) := '202020202020205468652055524C20746F20726564697265637420746F0A202A2040706172616D207B737472696E677D2020205B636F6E6669672E6974656D73546F5375626D69745D20202020202020202054686520415045582070616765206974656D';
wwv_flow_api.g_varchar2_table(8) := '7320746F207375626D697420692E652E207570646174696E672073657373696F6E207374617465207072696F7220746F207468652072656469726563740A202A2040706172616D207B626F6F6C65616E7D20205B636F6E6669672E65786563757465506C';
wwv_flow_api.g_varchar2_table(9) := '73716C5D20202020202020202020747275652F66616C73652069662077652061726520746F206578656375746520616E6420504C53514C207072696F7220746F207468652072656469726563740A202A2F0A464F532E7574696C732E6E61766967617469';
wwv_flow_api.g_varchar2_table(10) := '6F6E203D2066756E6374696F6E20286461436F6E746578742C20636F6E66696729207B0A0A0976617220706C7567696E4E616D65203D2027464F53202D205265646972656374272C206D65203D20746869733B0A09617065782E64656275672E696E666F';
wwv_flow_api.g_varchar2_table(11) := '28706C7567696E4E616D652C20636F6E666967293B0A0A096D652E7265646972656374203D2066756E6374696F6E2028636F6E66696729207B0A090976617220637478203D2077696E646F775B636F6E6669672E636F6E746578745D3B0A09092F2F2065';
wwv_flow_api.g_varchar2_table(12) := '786563757465207468652074726967676572696E6720656C656D656E742065787072657373696F6E0A09096966202820636F6E6669672E74726967676572696E67456C656D656E744578707220297B0A0909096C65742074726967676572696E67456C65';
wwv_flow_api.g_varchar2_table(13) := '6D656E74203D20636F6E6669672E74726967676572696E67456C656D656E74457870722E63616C6C286461436F6E74657874293B0A090909636F6E6669672E75726C203D20636F6E6669672E75726C2E7265706C61636528272354524947474552494E47';
wwv_flow_api.g_varchar2_table(14) := '5F454C454D454E5423272C20275C2727202B2074726967676572696E67456C656D656E74202B20275C2727293B0A09097D0A090969662028636F6E6669672E6E657757696E646F77203D3D3D207472756529207B0A0909092F2F204469616C6F67732077';
wwv_flow_api.g_varchar2_table(15) := '696C6C206E65766572206265206F70656E656420696E2061206E65772077696E646F772072696768743F0A0909096374782E617065782E6E617669676174696F6E2E6F70656E496E4E657757696E646F7728636F6E6669672E75726C290A09097D20656C';
wwv_flow_api.g_varchar2_table(16) := '7365207B0A0909092F2F2045786563757465207265646972656374696F6E0A0909096374782E617065782E6E617669676174696F6E2E726564697265637428636F6E6669672E75726C290A09097D0A097D0A096D652E616A61785265646972656374203D';
wwv_flow_api.g_varchar2_table(17) := '2066756E6374696F6E2028636F6E6669672C206461436F6E7465787429207B0A0909766172206C6F6164696E67496E64696361746F72466E2C207265717565737444617461203D207B7D2C0A0909097370696E6E657253657474696E6773203D20636F6E';
wwv_flow_api.g_varchar2_table(18) := '6669672E7370696E6E657253657474696E67733B0A0A09092F2F204164642070616765206974656D7320746F207375626D697420746F20726571756573740A090969662028636F6E6669672E6974656D73546F5375626D697429207B0A09090972657175';
wwv_flow_api.g_varchar2_table(19) := '657374446174612E706167654974656D73203D20636F6E6669672E6974656D73546F5375626D69740A09097D0A0A090972657175657374446174612E783031203D20286461436F6E746578742E74726967676572696E67456C656D656E7429203F206461';
wwv_flow_api.g_varchar2_table(20) := '436F6E746578742E74726967676572696E67456C656D656E742E6964203A2027273B202F2F207468616E6B7320416C616E204172656E7473656E204A756C2D323032310A0A09092F2F636F6E66696775726573207468652073686F77696E6720616E6420';
wwv_flow_api.g_varchar2_table(21) := '686964696E67206F66206120706F737369626C65207370696E6E65720A0909696620287370696E6E657253657474696E67732E73686F775370696E6E657229207B0A0A0909092F2F20776F726B206F757420776865726520746F2073686F772074686520';

wwv_flow_api.g_varchar2_table(22) := '7370696E6E65720A0909097370696E6E657253657474696E67732E7370696E6E6572456C656D656E74203D20287370696E6E657253657474696E67732E73686F775370696E6E65724F6E526567696F6E29203F206166456C656D656E7473203A2027626F';
wwv_flow_api.g_varchar2_table(23) := '6479273B0A0909096C6F6164696E67496E64696361746F72466E203D202866756E6374696F6E2028656C656D656E742C2073686F774F7665726C617929207B0A090909097661722066697865644F6E426F6479203D20656C656D656E74203D3D2027626F';
wwv_flow_api.g_varchar2_table(24) := '6479273B0A0909090972657475726E2066756E6374696F6E2028704C6F6164696E67496E64696361746F7229207B0A0909090909766172206F7665726C6179243B0A0909090909766172207370696E6E657224203D20617065782E7574696C2E73686F77';
wwv_flow_api.g_varchar2_table(25) := '5370696E6E657228656C656D656E742C207B2066697865643A2066697865644F6E426F6479207D293B0A09090909096966202873686F774F7665726C617929207B0A0909090909096F7665726C617924203D202428273C64697620636C6173733D22666F';
wwv_flow_api.g_varchar2_table(26) := '732D726567696F6E2D6F7665726C617927202B202866697865644F6E426F6479203F20272D666978656427203A20272729202B2027223E3C2F6469763E27292E70726570656E64546F28656C656D656E74293B0A09090909097D0A090909090966756E63';
wwv_flow_api.g_varchar2_table(27) := '74696F6E2072656D6F76655370696E6E65722829207B0A090909090909696620286F7665726C61792429207B0A090909090909096F7665726C6179242E72656D6F766528293B0A0909090909097D0A0909090909097370696E6E6572242E72656D6F7665';
wwv_flow_api.g_varchar2_table(28) := '28293B0A09090909097D0A09090909092F2F746869732066756E6374696F6E206D7573742072657475726E20612066756E6374696F6E2077686963682068616E646C6573207468652072656D6F76696E67206F6620746865207370696E6E65720A090909';
wwv_flow_api.g_varchar2_table(29) := '090972657475726E2072656D6F76655370696E6E65723B0A090909097D3B0A0909097D29287370696E6E657253657474696E67732E7370696E6E6572456C656D656E742C207370696E6E657253657474696E67732E73686F775370696E6E65724F766572';
wwv_flow_api.g_varchar2_table(30) := '6C6179293B0A09097D0A0A09092F2F20537461727420414A41580A09097661722070726F6D697365203D20617065782E7365727665722E706C7567696E28636F6E6669672E616A61784964656E7469666965722C2072657175657374446174612C207B0A';
wwv_flow_api.g_varchar2_table(31) := '09090964617461547970653A20276A736F6E272C0A0909096C6F6164696E67496E64696361746F723A206C6F6164696E67496E64696361746F72466E2C0A0909097461726765743A206461436F6E746578742E62726F777365724576656E742E74617267';
wwv_flow_api.g_varchar2_table(32) := '65740A09097D293B0A0A09092F2F20526564697265637420616674657220414A41580A090970726F6D6973652E646F6E652866756E6374696F6E20286461746129207B0A0909096D652E72656469726563742864617461293B0A0909092F2F2074686973';
wwv_flow_api.g_varchar2_table(33) := '20697320726571756972656420666F72207768656E20776520617265206F70656E696E67206D6F64616C206469616C6F67732C20666F722061637475616C2072656469726563747320746865207061676520756E6C6F616473206D616B696E6720746869';
wwv_flow_api.g_varchar2_table(34) := '7320726564756E64616E740A090909617065782E64612E726573756D65286461436F6E746578742E726573756D6543616C6C6261636B2C2066616C7365293B0A09097D292E63617463682866756E6374696F6E2028726573756C7429207B0A090909636F';
wwv_flow_api.g_varchar2_table(35) := '6E6669672E6572726F72203D20726573756C743B0A090909617065782E6576656E742E7472696767657228646F63756D656E742E626F64792C2027666F732D75726C2D72656469726563742D6572726F72272C20636F6E666967293B0A09097D293B0A09';
wwv_flow_api.g_varchar2_table(36) := '7D0A0A096D655B28636F6E6669672E6974656D73546F5375626D6974207C7C20636F6E6669672E65786563757465506C73716C29203F2027616A6178526564697265637427203A20277265646972656374275D28636F6E6669672C206461436F6E746578';
wwv_flow_api.g_varchar2_table(37) := '74293B0A0A7D3B0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(58070503030232429)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_file_name=>'js/script.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '76617220464F533D77696E646F772E464F537C7C7B7D3B464F532E7574696C733D77696E646F772E464F532E7574696C737C7C7B7D2C464F532E7574696C732E6E617669676174696F6E3D66756E6374696F6E28652C6E297B76617220693D746869733B';
wwv_flow_api.g_varchar2_table(2) := '617065782E64656275672E696E666F2822464F53202D205265646972656374222C6E292C692E72656469726563743D66756E6374696F6E286E297B76617220693D77696E646F775B6E2E636F6E746578745D3B6966286E2E74726967676572696E67456C';
wwv_flow_api.g_varchar2_table(3) := '656D656E7445787072297B6C657420693D6E2E74726967676572696E67456C656D656E74457870722E63616C6C2865293B6E2E75726C3D6E2E75726C2E7265706C61636528222354524947474552494E475F454C454D454E5423222C2227222B692B2227';
wwv_flow_api.g_varchar2_table(4) := '22297D21303D3D3D6E2E6E657757696E646F773F692E617065782E6E617669676174696F6E2E6F70656E496E4E657757696E646F77286E2E75726C293A692E617065782E6E617669676174696F6E2E7265646972656374286E2E75726C297D2C692E616A';
wwv_flow_api.g_varchar2_table(5) := '617852656469726563743D66756E6374696F6E28652C6E297B76617220722C742C6F2C612C643D7B7D2C6C3D652E7370696E6E657253657474696E67733B652E6974656D73546F5375626D6974262628642E706167654974656D733D652E6974656D7354';
wwv_flow_api.g_varchar2_table(6) := '6F5375626D6974292C642E7830313D6E2E74726967676572696E67456C656D656E743F6E2E74726967676572696E67456C656D656E742E69643A22222C6C2E73686F775370696E6E65722626286C2E7370696E6E6572456C656D656E743D6C2E73686F77';
wwv_flow_api.g_varchar2_table(7) := '5370696E6E65724F6E526567696F6E3F6166456C656D656E74733A22626F6479222C743D6C2E7370696E6E6572456C656D656E742C6F3D6C2E73686F775370696E6E65724F7665726C61792C613D22626F6479223D3D742C723D66756E6374696F6E2865';
wwv_flow_api.g_varchar2_table(8) := '297B766172206E2C693D617065782E7574696C2E73686F775370696E6E657228742C7B66697865643A617D293B72657475726E206F2626286E3D2428273C64697620636C6173733D22666F732D726567696F6E2D6F7665726C6179272B28613F222D6669';
wwv_flow_api.g_varchar2_table(9) := '786564223A2222292B27223E3C2F6469763E27292E70726570656E64546F287429292C66756E6374696F6E28297B6E26266E2E72656D6F766528292C692E72656D6F766528297D7D292C617065782E7365727665722E706C7567696E28652E616A617849';
wwv_flow_api.g_varchar2_table(10) := '64656E7469666965722C642C7B64617461547970653A226A736F6E222C6C6F6164696E67496E64696361746F723A722C7461726765743A6E2E62726F777365724576656E742E7461726765747D292E646F6E65282866756E6374696F6E2865297B692E72';
wwv_flow_api.g_varchar2_table(11) := '656469726563742865292C617065782E64612E726573756D65286E2E726573756D6543616C6C6261636B2C2131297D29292E6361746368282866756E6374696F6E286E297B652E6572726F723D6E2C617065782E6576656E742E7472696767657228646F';
wwv_flow_api.g_varchar2_table(12) := '63756D656E742E626F64792C22666F732D75726C2D72656469726563742D6572726F72222C65297D29297D2C695B6E2E6974656D73546F5375626D69747C7C6E2E65786563757465506C73716C3F22616A61785265646972656374223A22726564697265';
wwv_flow_api.g_varchar2_table(13) := '6374225D286E2C65297D3B0A2F2F2320736F757263654D617070696E6755524C3D7363726970742E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(58081986561659758)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_file_name=>'js/script.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B22464F53222C2277696E646F77222C227574696C73222C226E617669676174696F6E222C226461436F6E74657874222C22636F6E6669';
wwv_flow_api.g_varchar2_table(2) := '67222C226D65222C2274686973222C2261706578222C226465627567222C22696E666F222C227265646972656374222C22637478222C22636F6E74657874222C2274726967676572696E67456C656D656E7445787072222C2274726967676572696E6745';
wwv_flow_api.g_varchar2_table(3) := '6C656D656E74222C2263616C6C222C2275726C222C227265706C616365222C226E657757696E646F77222C226F70656E496E4E657757696E646F77222C22616A61785265646972656374222C226C6F6164696E67496E64696361746F72466E222C22656C';
wwv_flow_api.g_varchar2_table(4) := '656D656E74222C2273686F774F7665726C6179222C2266697865644F6E426F6479222C227265717565737444617461222C227370696E6E657253657474696E6773222C226974656D73546F5375626D6974222C22706167654974656D73222C2278303122';
wwv_flow_api.g_varchar2_table(5) := '2C226964222C2273686F775370696E6E6572222C227370696E6E6572456C656D656E74222C226166456C656D656E7473222C2273686F775370696E6E65724F7665726C6179222C22704C6F6164696E67496E64696361746F72222C226F7665726C617924';
wwv_flow_api.g_varchar2_table(6) := '222C227370696E6E657224222C227574696C222C226669786564222C2224222C2270726570656E64546F222C2272656D6F7665222C22736572766572222C22706C7567696E222C22616A61784964656E746966696572222C226461746154797065222C22';
wwv_flow_api.g_varchar2_table(7) := '6C6F6164696E67496E64696361746F72222C22746172676574222C2262726F777365724576656E74222C22646F6E65222C2264617461222C226461222C22726573756D65222C22726573756D6543616C6C6261636B222C226361746368222C2272657375';
wwv_flow_api.g_varchar2_table(8) := '6C74222C226572726F72222C226576656E74222C2274726967676572222C22646F63756D656E74222C22626F6479222C2265786563757465506C73716C225D2C226D617070696E6773223A22414145412C49414149412C4941414D432C4F41414F442C4B';
wwv_flow_api.g_varchar2_table(9) := '41414F2C4741437842412C49414149452C4D414151442C4F41414F442C49414149452C4F4141532C4741616843462C49414149452C4D41414D432C574141612C53414155432C45414157432C47414533432C4941416D43432C4541414B432C4B41437843';
wwv_flow_api.g_varchar2_table(10) := '432C4B41414B432C4D41414D432C4B41444D2C69424143574C2C4741453542432C454141474B2C534141572C534141554E2C47414376422C494141494F2C4541414D582C4F41414F492C4541414F512C53414578422C4741414B522C4541414F532C7342';
wwv_flow_api.g_varchar2_table(11) := '414175422C4341436C432C49414149432C4541416F42562C4541414F532C734241417342452C4B41414B5A2C4741433144432C4541414F592C4941414D5A2C4541414F592C49414149432C514141512C7542414177422C4941414F482C4541416F422C4D';
wwv_flow_api.g_varchar2_table(12) := '414533442C4941417242562C4541414F632C55414556502C454141494A2C4B41414B4C2C5741415769422C674241416742662C4541414F592C4B414733434C2C454141494A2C4B41414B4C2C57414157512C534141534E2C4541414F592C4D4147744358';
wwv_flow_api.g_varchar2_table(13) := '2C45414147652C614141652C5341415568422C45414151442C4741436E432C494141496B422C4541653642432C45414153432C4541437043432C454168426B42432C454141632C4741437243432C4541416B4274422C4541414F73422C67424147744274';
wwv_flow_api.g_varchar2_table(14) := '422C4541414F75422C6742414356462C45414159472C5541415978422C4541414F75422C6541476843462C45414159492C4941414F31422C45414132422C6B42414149412C45414155572C6B4241416B4267422C4741414B2C4741472F454A2C45414167';
wwv_flow_api.g_varchar2_table(15) := '424B2C6341476E424C2C45414167424D2C6541416B424E2C4541416D432C6F424141494F2C574141612C4F41437444582C454169423742492C45414167424D2C65416A427342542C454169424E472C4541416742512C6D424168423943562C4541417942';
wwv_flow_api.g_varchar2_table(16) := '2C51414158462C4541446E42442C454145512C53414155632C47414368422C49414149432C45414341432C4541415739422C4B41414B2B422C4B41414B502C59414159542C454141532C4341414569422C4D41414F662C49415776442C4F415649442C49';
wwv_flow_api.g_varchar2_table(17) := '414348612C45414157492C454141452C6B4341416F4368422C454141632C534141572C4941414D2C5941415969422C554141556E422C49414576472C5741434B632C47414348412C454141534D2C534145564C2C454141534B2C594153436E432C4B4141';
wwv_flow_api.g_varchar2_table(18) := '4B6F432C4F41414F432C4F41414F78432C4541414F79432C654141674270422C454141612C434143704571422C534141552C4F414356432C694241416B4231422C4541436C4232422C4F41415137432C4541415538432C61414161442C5341497842452C';
wwv_flow_api.g_varchar2_table(19) := '4D41414B2C53414155432C474143744239432C454141474B2C5341415379432C4741455A35432C4B41414B36432C47414147432C4F41414F6C442C454141556D442C6742414167422C4D41437643432C4F41414D2C53414155432C4741436C4270442C45';
wwv_flow_api.g_varchar2_table(20) := '41414F71442C4D414151442C454143666A442C4B41414B6D442C4D41414D432C51414151432C53414153432C4B41414D2C7942414130427A442C4F41493944432C45414149442C4541414F75422C654141694276422C4541414F30442C61414167422C65';
wwv_flow_api.g_varchar2_table(21) := '414169422C5941415931442C4541415144222C2266696C65223A227363726970742E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(58082309352659759)
,p_plugin_id=>wwv_flow_api.id(2674568769566617)
,p_file_name=>'js/script.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done


