$(document).ready(function() {
    const alwaysDeployedGroups = $('#tabs .has_nested');
    alwaysDeployedGroups.addClass('open');
    alwaysDeployedGroups.addClass('no-arrow');
    alwaysDeployedGroups.on('click', function(e) {
        $(this).toggleClass('open'); // reverts default action to open/close a group
    });

    // Scroll to the select element, or its parent group if it's a sub element
    $('#tabs .current').get(0)?.scrollIntoView(false);
});
