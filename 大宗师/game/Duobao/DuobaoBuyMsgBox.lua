 --[[
 --
 -- @authors shan 
 -- @date    2014-06-03 17:40:45
 -- @version 
 --
 --]]

require("game.GameConst")
local data_item_item = require("data.data_item_item")

local DuobaoBuyMsgBox = class("DuobaoBuyMsgBox", function (data)
	return require("utility.ShadeLayer").new()
end)

function DuobaoBuyMsgBox:ctor(param)
    self.upateListener = param.updateListen

    local proxy = CCBProxy:create()
    local ccbReader = proxy:createCCBReader()
    local rootnode = rootnode or {}

    self._rootnode = {}
    local node = CCBuilderReaderLoad("ccbi/arena/arena_msgBox.ccbi", proxy, self._rootnode)
    node:setPosition(display.width/2, display.height/2)
    self:addChild(node)

    self.id = 4008 
    self.nailiNum = data_item_item[self.id].para2
    self._rootnode["naili_num"]:setString(tostring(self.nailiNum))

    self.icon = self._rootnode["icon"]
    ResMgr.refreshIcon({itemBg = self.icon, id = self.id, resType = ResMgr.ITEM})
    
    setControlBtnEvent(self._rootnode["backBtn"],function()
        self:removeSelf()
        end)

    setControlBtnEvent(self._rootnode["buy_btn"],function()
        self:buyFunc()
        end)

    setControlBtnEvent(self._rootnode["use_btn"],function()
        self:useFunc()
        end)

    self:sendReq()
end

function DuobaoBuyMsgBox:useFunc()
    if self.itemNum > 0 then
        RequestHelper.useItem({
            callback = function(data)
                dump(data)
                game.player.m_energy = game.player.m_energy + data["2"][1]["n"]
                if self.upateListener ~= nil then 
                    self.upateListener()
                end 
                self:removeSelf()
            end,
            id = self.id,
            num = 1
            })
    else
       show_tip_label("无此道具")
    end
end


function DuobaoBuyMsgBox:buyFunc()
    if self.goldNum < self.costNum then
        show_tip_label("元宝不足")
    else
       RequestHelper.buy({
            callback = function(data)
                dump(data)
                if string.len(data["0"]) > 0 then
                    CCMessageBox(data["0"], "Tip")
                else
                    --购买并使用耐力丹
                    game.player:updateMainMenu({
                        silver = data["3"], 
                        gold = data["2"], 
                        naili = game.player.m_energy + self.nailiNum
                        })
                    PostNotice(NoticeKey.CommonUpdate_Label_Gold)
                    if self.upateListener ~= nil then 
                        self.upateListener()
                    end 
                    self:removeSelf()
                end
            end,
            id = self.shopId,
            n = 1,
            coinType = self.coinType,
            coin =self.costNum,
            auto = 1

        })
    end
end


function DuobaoBuyMsgBox:init()

    self.itemNum = self.data["2"] --玩家拥有的体力丹的数量
    local buyData = self.data["1"]
    self.goldNum = buyData["gold"]
    self.cnt = buyData["cnt"]       --剩余可购买数量
    self.costNum = buyData["coin"] --当前购买所需花费金钱
    self.shopId = buyData["id"]
    self.coinType = buyData["coinType"]


    self._rootnode["item_num"]:setString(self.itemNum)
    self._rootnode["gold_num"]:setString(self.costNum)

    if self.itemNum > 0 then
        self._rootnode["use_btn"]:setEnabled(true)
    else
        self._rootnode["use_btn"]:setEnabled(false)
    end

end

function DuobaoBuyMsgBox:sendReq()
    
    RequestHelper.getItemSaleData({
        callback = function(data)
            dump(data)
            if string.len(data["0"]) > 0 then 
                CCMessageBox(data["0"], "Error")
            else 
                self.data = data
                self:init()
            end 
        end,
        id = self.id
        })

end



return DuobaoBuyMsgBox