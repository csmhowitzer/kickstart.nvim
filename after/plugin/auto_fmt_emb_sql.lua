-- (invocation_expression
--   (member_access_expression [
--     name: (identifier) @name
--         (#any-of? @name "ExecuteAsync")
--
--     (generic_name
--         (identifier) @generic_name
--             (#any-of? @generic_name
--                 "QueryAsync"
--                 "QuerySingleOrDefaultAsync"))
--   ])
--
--   (argument_list
--     (argument [
--         (raw_string_literal) @raw_sql_string
--         (interpolated_string_expression) @inter_sql_string
--         (string_literal) @sql_string
--     ]))
-- )
--

local c_sharp_embedded_sql_query = [[
(invocation_expression
  (member_access_expression
    name: (identifier) @name
        (#any-of? @name "ExecuteAsync" "QueryAsync" "QuerySingleOrDefaultAsync"))

  (argument_list
    (argument [
        (raw_string_literal) @raw_sql_string
        (interpolated_string_expression) @inter_sql_string
        (string_literal) @sql_string
    ]))
)
]]

-- We want to use the sql LSP and Formatter and recognize the embedded sql
