$(function() {
    $(document).on('click', 'a', function(event) {
        var target = event.target;
        if (! target.target) {
            target.target = '_blank';
        }
    });
});
