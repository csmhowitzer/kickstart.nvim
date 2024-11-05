require('luasnip.session.snippet_collection').clear_snippets 'lua'
require('luasnip.session.snippet_collection').clear_snippets 'cs'

local ls = require 'luasnip'

local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node

local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep

local function copy(args)
  return args[1]
end

ls.add_snippets('lua', {
  s('el', fmt('<%= {} %>{}', { i(1), i(0) })),
  s('ei', fmt('<%= if {} do %>{}<% end %>{}', { i(1), i(2), i(0) })),
  s('hello', { t 'print("hello world")' }),
  s('fn', {
    -- Simple static text.
    t '//Parameters: ',
    -- function, first parameter is the function, second the Placeholders
    -- whose text it gets as input.
    f(copy, 2),
    t { '', 'function ' },
    -- Placeholder/Insert.
    i(1),
    t '(',
    -- Placeholder with initial text.
    i(2, 'int foo'),
    -- Linebreak
    t { ') {', '\t' },
    -- Last Placeholder, exit Point of the snippet. EVERY 'outer' SNIPPET NEEDS Placeholder 0.
    i(0),
    t { '', '}' },
  }),
})

ls.add_snippets('cs', {
  s('hello', { t 'print("hello csharp!")' }),
  s(
    'xuc',
    fmta(
      [[
        using Xunit;
        using static Xunit.Assert;

        namespace <a>;

        public class <b>
        {
            <c>
        }
      ]],
      {
        a = i(1, 'namespaceName'),
        b = i(2, 'ClassName'),
        c = i(3),
      }
    )
  ),
  s(
    'xuf',
    fmta(
      [[
          [Fact(DisplayName="<a>")]
          public void <b>_<c>() 
          {
              //Arrange
              <d>
              //Act

              //Assert
              Equal("", "I'm a test, and I'm not configured yet!!");
          }
      ]],
      {
        a = i(1, 'Display Test Name'),
        b = i(2, 'When'),
        c = i(3, 'Then'),
        d = i(4),
      }
    )
  ),
  s(
    'xut',
    fmta(
      [[
          [Theory]
          [InlinData(<a>)]
          public void <b>_<c>(<d> <e>) 
          {
              //Arrange
              <f>
              //Act

              //Assert
              Equal("", "I'm a test, and I'm not configured yet!!");
          }
      ]],
      {
        a = i(1, 'TestData'),
        b = i(2, 'When'),
        c = i(3, 'Then'),
        d = i(4, 'type'),
        e = i(5, 'name'),
        f = i(6),
      }
    )
  ),
  s(
    'exc',
    fmta(
      [[
        public class <a>_Exception : Exception
        {
            public <b>() : base() { }
            public <c>(string message) : base(message) { }
        }
      ]],
      {
        a = i(1, 'ClassName'),
        b = rep(1),
        c = rep(1),
      }
    )
  ),
})
