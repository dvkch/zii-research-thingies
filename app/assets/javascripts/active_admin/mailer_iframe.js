function computeIframeHeight(element) {
    const embedIframes = Array.from(element.contentWindow.document.querySelectorAll('iframe'))
        .map((embed) => computeIframeHeight(embed))
        .reduce((a, b) => a + b, 0);

    const iframeHeight = element.contentWindow.document.body.scrollHeight
    return embedIframes + iframeHeight;
}

function updateIframeHeight(element) {
    // minimum height when computing: can't put the height to 0 or the plain-text email previews will match `:root and height(0) { display: none }` that's a browser default
    const minHeight = 10

    // prevent page height flickering by adding a temporary element
    const placeholder = document.createElement('div');
    placeholder.setAttribute('style', `height: ${element.getAttribute('height') - minHeight}px`)
    element.parentNode.appendChild(placeholder);

    // computing
    element.setAttribute('height', minHeight);
    element.setAttribute('height', computeIframeHeight(element));
    placeholder.remove();
}

function onIframeLoad(element) {
    updateIframeHeight(element)

    // add triggers to nested iframes
    element.contentWindow.document.querySelectorAll('iframe').forEach((nested_iframe) => {
        nested_iframe.setAttribute('scrolling', 'no');
        nested_iframe.addEventListener('load', () => { updateIframeHeight(element) })
    })
}

(function() {
    function prepareIframeResize() {
        document.querySelectorAll('iframe.admin_email_preview_iframe').forEach((element) => {
            // prevent double init
            if (element.classList.contains('iframe-resizer-initialized')) {
                return
            }
            element.classList.add('iframe-resizer-initialized');

            // disable scrolling, add onload
            element.setAttribute('scrolling', 'no');
            element.setAttribute('onload', 'onIframeLoad(this)');

            // recompute height after tab change
            const parentTab = element.closest('.tab-content > div')
            if (parentTab) {
                const tabObserver = new MutationObserver(mutations => {
                    mutations
                        .filter(mutation => mutation.target.classList.contains('ui-tabs-panel'))
                        .forEach(() => updateIframeHeight(element))
                })
                tabObserver.observe(parentTab, { attributes: true })
            }

            // recompute height after deployed
            const parentDetails = element.closest('details')
            if (parentDetails) {
                const detailsObserver = new MutationObserver(mutations => {
                    mutations
                        .filter(mutation => mutation.attributeName === "open" )
                        .forEach(() => updateIframeHeight(element))
                })
                detailsObserver.observe(parentDetails, { attributes: true })
            }
        })
    }
    document.addEventListener("DOMContentLoaded", prepareIframeResize);
    document.addEventListener("DOMNodeInserted", prepareIframeResize);
}());
