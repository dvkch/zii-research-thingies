// Export fields
(function() {
    function setupFieldNameAutoCompletion() {
        $('.has_many_container.export_fields select[id$=_source_name]').each((_, element) => {
            // prevent double init
            if (element.classList.contains('export-field-autocompletion-initialized')) {
                return
            }
            element.classList.add('export-field-autocompletion-initialized');

            // add trigger
            $(element).on('select2:select', function () {
                let title = (this.selectedOptions[0].label);
                let csvField = this.parentElement.parentElement.querySelector('input[type="text"][id$=_export_name]');
                csvField.value = title
            });
        });
    }

    document.addEventListener("DOMContentLoaded", setupFieldNameAutoCompletion);
    document.addEventListener("DOMNodeInserted", setupFieldNameAutoCompletion);
})();

// Kind dependent edit forms
(function() {
    function updateKindDependantItems(select) {
        const visibilityClass = 'kind-' + ((select.selectedOptions[0].value) ?? '');

        // kind selection will modify visibility in all the form
        let elements = $(select).closest('form').find('li.input.kind-dependant')

        // we are editing an item in an has_many relationship, let's make sure it modifies only items in its own fieldset
        if ($(select).closest("fieldset.has_many_fields").length > 0) {
            elements = $(select).closest('fieldset').find('li.input.kind-dependant')
        }

        elements.each(function (_, input) {
            const visibility = $(input).hasClass(visibilityClass) ? '' : 'none';
            $(input).css('display', visibility);
        });
    }

    function setupKindDependantFields() {
        $('form fieldset select[id$=_kind]').each(function (_, element) {
            // prevent double init
            if (element.classList.contains('kind-dependant-initialized')) {
                return
            }
            element.classList.add('kind-dependant-initialized');

            // add trigger
            $(element).on('select2:select', (e) => updateKindDependantItems(e.target));
            updateKindDependantItems(element);
        })
    }

    document.addEventListener("DOMContentLoaded", setupKindDependantFields);
    document.addEventListener("DOMNodeInserted", setupKindDependantFields);
})();

// Deployable panels in admin
(function() {
    function deployPanelsWithErroneousInputs(event) {
        $('form details.panel:not([open]) .input .inline-errors')
            .each((_, item) => { $(item).closest('details').attr('open', 1) })
    }

    document.addEventListener("DOMContentLoaded", deployPanelsWithErroneousInputs);
    document.addEventListener("DOMNodeInserted", deployPanelsWithErroneousInputs);
})();
