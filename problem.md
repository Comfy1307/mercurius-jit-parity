We change resolvers and the schema while the server is running, and some responses don't follow. With jit on, after we swap a resolver with defineResolvers, queries that were already compiled keep calling the old one.

Separately, after extendSchema a query that failed before the extension keeps failing with the old validation error, even though the field exists now.

Changing the schema or resolvers while the server is running (defineResolvers, extendSchema, replaceSchema) should apply to the very next request, whether or not that query was seen or compiled before. Turning jit on, as a number or with the adaptive options, should not change that.
