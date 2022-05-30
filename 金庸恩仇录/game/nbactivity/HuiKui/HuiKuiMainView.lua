--
-- Author: Daneil
-- Date: 2015-03-14 15:56:17
--
 local MAX_ZORDER = 1111 
 require("game.Biwu.BiwuFuc")
 local data_item_item = require("data.data_item_item")
 local data_xianshishangdian_xianshishangdian = require("data.data_xianshishangdian_xianshishangdian")
 local HuiKuiMainView= class("HuiKuiMainView", function()
 		return display.newNode()
 end)


 function HuiKuiMainView:ctor(param)
   local viewSize = param.viewSize 
 	local proxy = CCBProxy:create()
 	self._rootnode = {} 
 	
    local node = CCBuilderReaderLoad("nbhuodong/chongzhihuikui_layer.ccbi", proxy, self._rootnode, self, viewSize)
    self:addChild(node) 

    local titleSize = self._rootnode["titlebng"]:getContentSize()
    self._rootnode["listbng"]:setContentSize(cc.size(display.width * 0.98 , param.viewSize.height - titleSize.height - 0))
    self._rootnode["listview"]:setContentSize(cc.size(display.width * 0.95 , param.viewSize.height- titleSize.height - 30))


    

    --[[local timetitleLabel = ui.newTTFLabelWithOutline({  text = "活动有效期:", 
                                            size = 22, 
                                            color = ccc3(255,255,255),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })
    self.timeLabel      = ui.newTTFLabelWithOutline({  text = "", 
                                            size = 22, 
                                            color = ccc3(30,255,0),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })


    local timetitleLabel1 = ui.newTTFLabelWithOutline({  text = "活动剩余时间:", 
                                            size = 22, 
                                            color = ccc3(255,255,255),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })
    self.timeLabel1      = ui.newTTFLabelWithOutline({  text = "", 
                                            size = 22, 
                                            color = ccc3(30,255,0),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })


    --]]

    self:getData(function() 
        self:setUpView()
    end
    )

end

function HuiKuiMainView:setUpView()

    local boardWidth = self._rootnode["listview"]:getContentSize().width 
    local boardHeight = self._rootnode["listview"]:getContentSize().height
    

    -- 创建 
    local function createFunc(index)
        local item = require("game.nbactivity.HuiKui.HuiKuiItemView").new()
        return item:create({
            index = index, 
            viewSize = CCSizeMake(boardWidth, boardHeight), 
            itemData = self._data[index + 1],
            confirmFunc = showBuyBox
            })
    end
    -- 刷新 
    local function refreshFunc(cell, index)
        cell:refresh({
            index = index, 
            itemData = self._data[index + 1],
            confirmFunc = showBuyBox
            })
    end
    local cellContentSize = require("game.nbactivity.HuiKui.HuiKuiItemView").new():getContentSize()
    self.ListTable = require("utility.TableViewExt").new({
        size        = CCSizeMake(boardWidth, boardHeight), 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum     = #self._data, 
        cellSize    = cellContentSize, 
        direction   = kCCScrollViewDirectionVertical
        })
    self.ListTable:setPosition(0, 0)
    self._rootnode["listview"]:addChild(self.ListTable)
    self._rootnode["listview"]:setPositionY(self._rootnode["listview"]:getPositionY() + 5)

end

function HuiKuiMainView:getData(func)
    local init = function(data)
        self._data = {1,2,3,34,45,1}
        func()
    end
    self._data = {1,2,3,34,45,1,231,1}
    func()
    --[[RequestHelper.xianshiShopSystem.getBaseInfo({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end
                })--]]

end

function HuiKuiMainView:clear()
    if self._schedule then
        self._scheduler.unscheduleGlobal(self._schedule)
    end
    require("game.Spirit.SpiritCtrl").clear()
end

 
return HuiKuiMainView 
