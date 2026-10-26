when we change resolvers/schema on a live server there are some cases where things dont update. if you have jit enabled and change a resolver using defineResolvers. Any query that has been compiled will still use the previous resolver.

After extending the schema using extendSchema a query that was erroring out will continue to error out with the old schema error. even though it has the field now. 

if a request is currently going through the hooks it can also continue to use the previous resolver when the query runs.

any changes made to the schema/resolvers on a running server should affect the next request regardless of if the query was previously used or not. this includes changing defineResolvers, extendSchema and replaceSchema. If a request is still going through the hooks when the change is made it should get the change too. Enabling jit with a number or the options for adaptive should not impact this.
