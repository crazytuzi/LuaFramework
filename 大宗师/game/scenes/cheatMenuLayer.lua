 --[[
 --
 -- @authors shan 
 -- @date    2014-11-03 21:04:18
 -- @version 
 --
 --]]

local cheatMenuLayer = class("cheatMenuLayer",function ( )
	return display.newLayer("cheatMenuLayer")
end)

function cheatMenuLayer:ctor( ... )

    local function onAddItem(tag)

        local editBox = ui.newEditBox({
            image = "#mm_energy_bg.png",
            size = CCSizeMake(250, 50),
            listener = function(param, x, y, z)

            end
        })
        editBox:setPosition(display.width / 2, display.height / 2)
        self:addChild(editBox, 10011)
        --
        local onBtn = require("utility.CommonButton").new({
            img = "#mm_silver.png",
            listener = function ()



                if tag == 1 then
                    local item = require("data.data_item_item")[checknumber(editBox:getText())]
                    if item == nil then
                        return
                    end

                    RequestHelper.gmAdd({
                        callback = function(data)
                            dump(data)
                        end,
                        id = editBox:getText(),
                        n = 5,
                        t = item.type
                    })
                elseif tag == 2 then
                    RequestHelper.gmAdd({
                        callback = function()

                        end,
                        id = 1,
                        n = checkint(editBox:getText()),
                        t = 0
                    })
                elseif tag == 3 then
                    RequestHelper.gmAdd({
                        callback = function(data)
                            dump(data)
                        end,
                        id = 2,
                        n = checkint(editBox:getText()),
                        t = 0
                    })
                elseif tag == 4 then
                    RequestHelper.gmAdd({
                        callback = function(data)
                            dump(data)
                        end,
                        id = checkint(editBox:getText()),
                        n = 3,
                        t = 8
                    })
                elseif tag == 5 then
                    RequestHelper.gmAdd({
                        callback = function(data)
                            dump(data)
                        end,
                        id = checkint(editBox:getText()),
                        n = 1,
                        t = 1
                    })
                elseif tag == 6 then
                    RequestHelper.gmAdd({
                        callback = function(data)
                            dump(data)
                        end,
                        id = 3,
                        n = checkint(editBox:getText()),
                        t = 0
                    })
                elseif tag == 7 then
                    RequestHelper.gmAdd({
                        callback = function(data)
                            dump(data)
                        end,
                        id = checkint(editBox:getText()),
                        n = 1,
                        t = 6
                    })
                elseif tag == 8 then
                    RequestHelper.gmAdd({
                        callback = function(data)
                            dump(data)
                        end,
                        id = editBox:getText(),
                        n = 11,
                        t = 5
                    })
                elseif tag == 9 then
                    RequestHelper.formation.unload({
                        callback = function(data)
                        --                            dump(data)
                        end,
                        pos = editBox:getText()
                    })
                elseif tag == 10 then
                    RequestHelper.gmAdd({
                        callback = function(data)
                            dump(data)
                        end,
                        id = editBox:getText(),
                        n = 20,
                        t = 4
                    })
                elseif tag == 11 then
                    RequestHelper.gmAdd({
                        callback = function(data)
                            dump(data)
                        end,
                        id = editBox:getText(),
                        n = 1,
                        t = 3
                    })
                elseif tag == 12 then


                end
                editBox:removeSelf()
            end
        })
        onBtn:setPosition(editBox:getContentSize().width, 0)
        editBox:addChild(onBtn)
    end

    local addBtn = ui.newTTFLabelMenuItem({
        text = "添加物品",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function(tag)
            -- PostNotice(NoticeKey.LOCK_BOTTOM)
            onAddItem(tag)
        end,
        tag = 1
    })
    --
    local addGold = ui.newTTFLabelMenuItem({
        text = "添加金币",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function(tag)
            onAddItem(tag)
        end,
        tag = 2
    })

    local addSilver = ui.newTTFLabelMenuItem({
        text = "添加银币",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function(tag)
            onAddItem(tag)
        end,
        tag = 3
    })

    local addHero = ui.newTTFLabelMenuItem({
        text = "添加武将",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function(tag)
            onAddItem(tag)
        end,
        tag = 4
    })

    local addEquip = ui.newTTFLabelMenuItem({
        text = "添加装备",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function(tag)
            onAddItem(tag)
        end,
        tag = 5
    })

    local addTili = ui.newTTFLabelMenuItem({
        text = "添加体力",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function(tag)
            onAddItem(tag)
        end,
        tag = 6
    })

    local addJingYuan = ui.newTTFLabelMenuItem({
        text = "添加精元",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function(tag)
            onAddItem(tag)
        end,
        tag = 7
    })

    local addherosoul = ui.newTTFLabelMenuItem({
        text = "侠客碎片",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function(tag)
            onAddItem(tag)
        end,
        tag = 8
    })

    local unloadHero = ui.newTTFLabelMenuItem({
        text = "下阵英雄",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function(tag)
            onAddItem(tag)
        end,
        tag = 9
    })

    local addReward = ui.newTTFLabelMenuItem({
        text = "添加奖励",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function()
            RequestHelper.getRewardCenter({
                callback = function(data)
                    dump(data)
                end
            })
        end
    })
    local addStar = ui.newTTFLabelMenuItem({
        text = "添加星星",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function()
            RequestHelper.gmAddStar({
                callback = function(data)
                    dump(data)
                end
            })
        -- RequestHelper.game.login_3rd({
        --  name = "xiaoxue",
        --  rid = "1",
        --  uin = self.uin,
        --  sessionId = self.sessionId,
        --  callback = function ( data )
        --      print("999999999999")
        --      dump(data)
        --  end
        --  })
        end
    })

    local addSkill = ui.newTTFLabelMenuItem({
        text = "添加武学",
        color = display.COLOR_BLUE,
        size = 26,
        listener = function(tag)
            onAddItem(tag)
        -- RequestHelper.game.login_3rd({
        --  name = "",
        --  rid = "",
        --  uin = self.uin,
        --  sessionId = self.sessionId,
        --  callback = function ( data )
        --      print("999999999999")
        --      dump(data)
        --  end
        --  })
        end,
        tag = 10
    })

    local addEquipFragment = ui.newTTFLabelMenuItem({
        text = "添加装备碎片",
        color = display.COLOR_GREEN,
        size = 26,
        listener = function(tag)
            onAddItem(tag)
        -- RequestHelper.game.login_3rd({
        --  name = "",
        --  rid = "",
        --  uin = self.uin,
        --  sessionId = self.sessionId,
        --  callback = function ( data )
        --      print("999999999999")
        --      dump(data)
        --  end
        --  })
        end,
        tag = 11
    })
    local addAllHeros = ui.newTTFLabelMenuItem({
        text = "添加所有侠客",
        color = display.COLOR_GREEN,
        size = 26,
        listener = function(tag)
            RequestHelper.gmAddAllCard({
                callback = function ( data )
                    dump(data)
                end
            })
        end,
        tag = 12
    })
    local resetAllCount = ui.newTTFLabelMenuItem({
        text = "重置挑战次数",
        color = display.COLOR_GREEN,
        size = 26,
        listener = function(tag)
            RequestHelper.gmResetAllCounts({
                callback = function ( data )
                    dump(data)
                end
            })
        end,
        tag = 13
    })
    --    addGold, addSilver, addHero, addEquip, addTili, addJingYuan,
    if(GAME_DEBUG == true) then

        local testMenu = ui.newMenu({addBtn, addGold, addHero, addSilver,addherosoul, unloadHero, addReward, addStar, addSkill, addEquipFragment,addAllHeros,resetAllCount})
        testMenu:alignItemsVertically()
        testMenu:setPosition(display.width * 0.12, display.height * 0.62)
        self:addChild(testMenu, 19)

        local testAnim = ui.newTTFLabelMenuItem({
        text = "动画测试界面",
        color = display.COLOR_GREEN,
        size = 26,
        listener = function(tag)
            local scene  = require("game.Setting.SettingScene").new()
            display.replaceScene(scene)
           
        end,        
        })

        local testFile  = ui.newTTFLabelMenuItem({
        text = "测试文件读写",
        color = display.COLOR_GREEN,
        size = 26,
        listener = function(tag)

           self:testFile()
        end,        
        })

        testFile:setPosition(0,-100)

        local settingMenu = ui.newMenu({testAnim,testFile})    
        settingMenu:setPosition(display.width * 0.7, display.height * 0.62)
        self:addChild(settingMenu)



        local function isCnChar( str )
            local len  = string.len(str)
            local left = len
            local cnt  = 0

            for i=1,len do
                local curByte = string.byte(str, i)
                -- '￥' = 239
                if(curByte > 127) then
                    dump(curByte)
                    return true
                end
            end

            return false
        end

        -- local str = "m12345678"
        -- if(isCnChar(str) == true) then
        --     device.showAlert(str, "中文")
        -- end
        -- local length = string.utf8len(str)
        -- device.showAlert(length,string.len(str))





    end
end



function cheatMenuLayer:testFile()
    local function errfff()
        print("heheheh")
    end

    local arr = {1,2}

    local function yeyye()
        print("arr"..arr[3])
         
    end


    local x,err = safe_call(yeyye)

    print("msgis ")
    dump(x)

end

function cheatMenuLayer:getCellValue(cellData)
    local cellValue = 0
    local isOnline = cellData.isOnline    or 0
    local level    = cellData.level       or 1
    local zhanli   = cellData.battlepoint or 0

    --1在线
    cellValue = cellValue + isOnline * 1000000
    --2等级
    cellValue = cellValue + level    * 10000
    --3战斗力
    cellValue = cellValue + zhanli   / 100

    --id


    return cellValue
end











return cheatMenuLayer