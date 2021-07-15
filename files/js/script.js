/* globals apex */

var FOS = window.FOS || {};
FOS.utils = window.FOS.utils || {};

/**
 * This function evaluates the given parameters (the url redirect) and stops the current dynamic actions
 * if the condition demands so.
 *
 * @param {object}   daContext                      Dynamic Action context as passed in by APEX
 * @param {object}   config                         Configuration object holding the url redirect configuration
 * @param {string}   config.context                 Which window context is being redirected e.g. [window,parent,top]
 * @param {string}   config.url                     The URL to redirect to
 * @param {string}   [config.itemsToSubmit]         The APEX page items to submit i.e. updating session state prior to the redirect
 * @param {boolean}  [config.executePlsql]          true/false if we are to execute and PLSQL prior to the redirect
 */
FOS.utils.navigation = function (daContext, config) {

	var pluginName = 'FOS - Redirect', me = this;
	apex.debug.info(pluginName, config);

	me.redirect = function (config) {
		var ctx = window[config.context];
		if (config.newWindow === true) {
			// Dialogs will never be opened in a new window right?
			ctx.apex.navigation.openInNewWindow(config.url)
		} else {
			// Execute redirection
			ctx.apex.navigation.redirect(config.url)
		}
	}
	me.ajaxRedirect = function (config, daContext) {
		var loadingIndicatorFn, requestData = {},
			spinnerSettings = config.spinnerSettings;

		// Add page items to submit to request
		if (config.itemsToSubmit) {
			requestData.pageItems = config.itemsToSubmit
		}

		requestData.x01 = (daContext.triggeringElement) ? daContext.triggeringElement.id : ''; // thanks Alan Arentsen Jul-2021

		//configures the showing and hiding of a possible spinner
		if (spinnerSettings.showSpinner) {

			// work out where to show the spinner
			spinnerSettings.spinnerElement = (spinnerSettings.showSpinnerOnRegion) ? afElements : 'body';
			loadingIndicatorFn = (function (element, showOverlay) {
				var fixedOnBody = element == 'body';
				return function (pLoadingIndicator) {
					var overlay$;
					var spinner$ = apex.util.showSpinner(element, { fixed: fixedOnBody });
					if (showOverlay) {
						overlay$ = $('<div class="fos-region-overlay' + (fixedOnBody ? '-fixed' : '') + '"></div>').prependTo(element);
					}
					function removeSpinner() {
						if (overlay$) {
							overlay$.remove();
						}
						spinner$.remove();
					}
					//this function must return a function which handles the removing of the spinner
					return removeSpinner;
				};
			})(spinnerSettings.spinnerElement, spinnerSettings.showSpinnerOverlay);
		}

		// Start AJAX
		var promise = apex.server.plugin(config.ajaxIdentifier, requestData, {
			dataType: 'json',
			loadingIndicator: loadingIndicatorFn,
			target: daContext.browserEvent.target
		});

		// Redirect after AJAX
		promise.done(function (data) {
			me.redirect(data);
			// this is required for when we are opening modal dialogs, for actual redirects the page unloads making this redundant
			apex.da.resume(daContext.resumeCallback, false);
		}).catch(function (result) {
			config.error = result;
			apex.event.trigger(document.body, 'fos-url-redirect-error', config);
		});
	}

	me[(config.itemsToSubmit || config.executePlsql) ? 'ajaxRedirect' : 'redirect'](config, daContext);

};


