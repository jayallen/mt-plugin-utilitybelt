var ubRebuild; 
var ubRebuilding;  
var ubRebuildMsg;
var ubRebuildMsgSpan;
var progressBar;
var progressBarMsg;
var ubData;
var paramData = new Array('script_url', 'blog_id', 'offset', 'limit', 'total', 'start_time', 'entry_id', 'is_new', 'old_status', 'old_preview', 'old_next', 'fs', 'with_indexes', 'no_static', 'template_id', 'templatemap_id', 'return_args', 'tmpl_id', 'single_template', 'rebuilding_label', 'complete', 'incomplete', 'tmpl_name', 'build_type', 'build_next');
var monitorTimer;
var windowID = Math.random();

function utilityCallRebuild(script_url, blog_id, type) {  
    // Lets do some cookie checking here
    var ubRebuildWindowCookie = $.cookie('ubRebuildWindowCookie');
    if (ubRebuildWindowCookie && ubRebuildWindowCookie != windowID) {
        monitorTimer = setTimeout('utilityRebuildMonitor()', 200);
        return;
    }    
      
    $.cookie('ubRebuildCookie', 1);
    $.cookie('ubRebuildWindowCookie', windowID);
    clearTimeout(monitorTimer);
    
    var args = {
        '__mode': 'start_rebuild',
        'json': 1,
        'blog_id': blog_id,
        'type': type
    };
    
    for (var name in ubData) {
        args[name] = ubData[name];
    }
    
    if(!script_url)
        script_url = ubData.script_url;
    
    $.getJSON(script_url, args, utilityRebuilding);
        
    ubRebuild.ajaxSend(function(){
        ubRebuild.hide();
        ubRebuilding.show(); 
        ubRebuildMsg.hide();
        ubData = {};
    });
}

function utilityRebuilding(param, textStatus) { 
    // Set the ubRebuildDataCookie first
    var ubRebuildDataCookie = '';
    for (var i = 0; i < paramData.length; i++) {
        var name = paramData[i];
        if(!param[name])
            continue;
            
        ubRebuildDataCookie += name + '=' + param[name] + '&';
    }
    $.cookie('ubRebuildDataCookie', ubRebuildDataCookie);
       
    progressBarMsg.text(param.rebuilding_label);
    if(param.complete) {
        progressBar.css('background-position', param.incomplete + '% 0');
        progressBar.removeClass('progress-bar-indeterminate');
    } else {
        progressBar.addClass('progress-bar-indeterminate');
    }
    ubRebuild.hide();
    ubRebuilding.show();
    
    // Call rebuilding again
    ubData = {};
    
    if(param.tmpl_name == 'rebuilding.tmpl') {        
        for (var i = 0; i < paramData.length; i++) {
            var name = paramData[i];
            if(!param[name])
                continue;
            ubData[name] = escape(param[name]);
        }
        ubData['__mode'] = 'rebuild';
        ubData['type'] = param.build_type;
        ubData['next'] = param.build_next;
        
        setTimeout('utilityCallRebuild()', 200);
    } 
    
    if(param.tmpl_name == 'popup/rebuilt.tmpl') { // Rebuilt
        $.cookie('ubRebuildCookie', null);
        $.cookie('ubRebuildWindowCookie', null);
        ubRebuild.show();
        ubRebuilding.hide(); 
        ubRebuildMsgSpan.text(param.rebuilt_label);
        ubRebuildMsg.removeClass('hidden');
        ubRebuildMsg.slideDown("fast"); 
        
        // Reset     
        progressBarMsg.text(progressBarMsg.attr('mt:default'));
        progressBar.addClass('progress-bar-indeterminate');
        monitorTimer = setTimeout('utilityRebuildMonitor()', 200);
    } 
}

function utilityRebuildMonitor() {
    var ubRebuildCookie = $.cookie('ubRebuildCookie');
    var ubRebuildDataCookie = $.cookie('ubRebuildDataCookie');
    
    if((ubRebuildCookie && ubRebuildDataCookie) || ubRebuild.css('display') == 'none') { // Somewhere asked for a rebuild so update this 
        var ubRebuildDataArray = ubRebuildDataCookie.split('&');
        var param = {};
        for (var i = 0; i < ubRebuildDataArray.length; i++) {
            var keyValue = ubRebuildDataArray[i].split('=');
            param[keyValue[0]] = keyValue[1];
        }
        utilityRebuilding(param, null);
    } else {
        monitorTimer = setTimeout('utilityRebuildMonitor()', 200);  
    }    
}

$(document).ready(function(){ 
    ubRebuild       = $('#utilitybelt-rebuild');
    ubRebuilding    = $('#utilitybelt-rebuilding')
    ubRebuildMsg    = $('#utility-belt-msg');
    ubRebuildMsgSpan = $('#utility-belt-msg > span');
    progressBar     = $('#utilitybelt-rebuilding .progress-bar');
    progressBarMsg  = $('#utilitybelt-rebuilding .progress-bar > span');  
    ubRebuildMsg.hide();      
    
    utilityRebuildMonitor();
});
$(window).unload(function(e) { // Unset the windowID cookie if we close the window so another one can pick up the rebuild
    var ubRebuildWindowCookie = $.cookie('ubRebuildWindowCookie');
    if (ubRebuildWindowCookie && ubRebuildWindowCookie == windowID) {
        $.cookie('ubRebuildWindowCookie', null);
    }    
});