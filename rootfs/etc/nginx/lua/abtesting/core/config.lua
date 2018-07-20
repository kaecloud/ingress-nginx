local _M = {}

_M.RULES_KEY = 'abtesting_rules'

_M.filters = {
    ua = require 'abtesting.filter.ua',
    header = require 'abtesting.filter.header',
    query = require 'abtesting.filter.query',
    ip = require 'abtesting.filter.ip',
    cookie = require 'abtesting.filter.cookie'
}

return _M
