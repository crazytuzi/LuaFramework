local function getItem(itemId)
    print("getItem", itemId)
    return require(string.format("Config.PvpRankRewardRelation_%d", itemId))
end

PvpRankRewardRelation = {
    desc = {
        step = "#竞技阶级",
        rank = "#排名",
        PVPCoin = "声望",
        rawGold = "基础金币"
    },
    key = {"step", "rank"},
    items_count = 6,
    items = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
        [6] = {}
    }
}

PvpRankRewardRelation.items = setmetatable(
    {_items = PvpRankRewardRelation.items},
    {
        __index = function(obj, key)
            if not obj._items[key] then
                require("Common.LocalData")
                LocalData:addNoneConfigItem("PvpRankRewardRelation", key)
                return
            end
            local value = getItem(key)
            if not value then
                require("Common.LocalData")
                LocalData:addNoneConfigItem("PvpRankRewardRelation", key)
            end
            return value
        end,

        __pairs= function(obj)
            return next, obj._items, nil
        end,

        __ipairs= function(obj)
            return next, obj._items, 0
        end,

        __len= function(obj)
            return #obj._items
        end,

        __newindex= function(obj, key, val)
        end,

        __metatable= false,
})
