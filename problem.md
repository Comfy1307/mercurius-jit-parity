We change resolvers and the schema while the server is running, and some responses don't follow. With jit on, after we swap a resolver with defineResolvers, queries that were already compiled keep calling the old one.

Separately, after extendSchema a query that failed before the extension keeps failing with the old validation error, even though the field exists now.

It also goes wrong for requests already in flight. If a resolver is swapped while a request is still waiting in its hooks, that request can still run the old resolver once it executes.

Changing the schema or resolvers while the server is running (defineResolvers, extendSchema, replaceSchema) should apply to the very next request, whether or not that query was seen or compiled before. It should also apply to any request that hasn't started executing yet. Turning jit on, as a number or with the adaptive options, should not change that.
