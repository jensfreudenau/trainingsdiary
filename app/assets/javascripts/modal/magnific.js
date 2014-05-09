/**
 * Created with JetBrains RubyMine.
 * User: jensfreudenau
 * Date: 20.10.13
 * Time: 16:03
 * To change this template use File | Settings | File Templates.
 */
    // Inline popups
jQuery('#inline-popups').magnificPopup({
    delegate: 'a',
    removalDelay: 500, //delay removal by X to allow out-animation
    callbacks: {
        beforeOpen: function() {
            this.st.mainClass = this.st.el.attr('data-effect');
        }
    },
    midClick: true // allow opening popup on middle mouse click. Always set it to true if you don't provide alternative source.
});


// Image popups
jQuery('#image-popups').magnificPopup({
    delegate: 'a',
    type: 'image',
    removalDelay: 500, //delay removal by X to allow out-animation
    callbacks: {
        beforeOpen: function() {
            // just a hack that adds mfp-anim class to markup
            this.st.image.markup = this.st.image.markup.replace('mfp-figure', 'mfp-figure mfp-with-anim');
            this.st.mainClass = this.st.el.attr('data-effect');
        }
    },
    closeOnContentClick: true,
    midClick: true // allow opening popup on middle mouse click. Always set it to true if you don't provide alternative source.
});


// Hinge effect popup
jQuery('a.hinge').magnificPopup({
    mainClass: 'mfp-with-fade',
    removalDelay: 1000, //delay removal by X to allow out-animation
    callbacks: {
        beforeClose: function() {
            this.content.addClass('hinge');
        },
        close: function() {
            this.content.removeClass('hinge');
        }
    },
    midClick: true
});