$(document).ready(function () {
  $('[data-forage-select2-widget="true"]').each(
    function (index, node) {
      // Extract configuration options from the HTML element
      var baseUrl = node.dataset.url;
      var field = node.dataset.field;
      // Next, we create some extra storage to help us convert offset-based pagination
      // into cursor-based pagination.
      //
      // With offset-based pagination, the pages are numbered (i.e. 1, 2, 3...).
      // On the other hand, with cursor-based pagination, we have only an abstract token,
      // which serves as a link to the next page.
      //
      // To convert page numbers to tokens, we simply define a map that stores the token
      // for every page number.
      // That way, Select2 can continue to ask for page number 1, 2, 3, etc. because we
      // know how to convert the page number into out tokens
      var lastTerm = "";
      var pageToAfterToken = { 1: null };
      // Turn the node into a select2 box
      $(node).select2({
        // Use AJAX to get JSON data from the server
        ajax: {
          url: baseUrl,
          data: function (params) {
            var page = params.page || 1;
            var term = params.term || "";
            // Build the query
            var query = {};
            query["_search[" + field + "][op]"] = "contains";
            query["_search[" + field + "][val]"] = term;
            // If we don't have a token or if the query string has changed,
            // we don't want to reuse the pagination token.
            var afterToken = pageToAfterToken[page];
            if (afterToken && lastTerm == term) {
              query["_pagination[after]"] = afterToken;
            }

            // Query parameters will be ?search=[term]&type=public
            return query;
          },
          processResults: function (data, params) {
            var page = params.page || 1
            lastTerm = params.term || "";
            // With the request for the current page we also receive
            // the token for the next page
            pageToAfterToken[page + 1] = data.pagination.after;
            return data;
          },
          dataType: 'json',
          placeholder: "..."
        }
      });
    })
});