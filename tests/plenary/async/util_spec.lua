require('plenary.async').tests.add_to_env()
local block_on = a.util.block_on
local eq = assert.are.same
local id = a.util.id

describe('async await util', function()
    describe('block_on', function()
        a.it('should block_on', function()
            local fn = function()
                a.util.sleep(100)
                return 'hello'
            end

            local res = fn()
            eq(res, 'hello')
        end)

        a.it('should work even when failing', function()
            local nonleaf = function()
                eq(true, false)
            end

            local stat = pcall(block_on, nonleaf)
            eq(stat, false)
        end)
    end)

    describe('protect', function()
        a.it('should be able to protect a non-leaf future', function()
            local nonleaf = function()
                error('This should error')
                return 'return'
            end

            local stat, ret = pcall(nonleaf)
            eq(false, stat)
            assert(ret:match('This should error'))
        end)

        a.it(
            'should be able to protect a non-leaf future that doesnt fail',
            function()
                local nonleaf = function()
                    return 'didnt fail'
                end

                local stat, ret = pcall(nonleaf)
                eq(stat, true)
                eq(ret, 'didnt fail')
            end
        )
    end)

    local function sleep(msec)
        return function()
            a.util.sleep(msec)
            return msec
        end
    end

    describe('race', function()
        a.it('should return the first result', function()
            local funcs = vim.tbl_map(sleep, { 300, 400, 100, 200 })
            local result = a.util.race(funcs)
            eq(result, 100)
        end)
    end)

    describe('run_first', function()
        a.it('should return the first result', function()
            local async_functions = vim.tbl_map(function(num)
                return function(callback)
                    return a.run(sleep(num), callback)
                end
            end, { 300, 400, 100, 200 })
            local result = a.util.run_first(async_functions)
            eq(result, 100)
        end)
    end)
end)
