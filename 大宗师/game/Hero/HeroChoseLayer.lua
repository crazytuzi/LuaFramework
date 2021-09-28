 --
 

local HeroChoseLayer = class("HeroChoseLayer", function (param)
    
	return require("utility.ShadeLayer").new()
end)



function HeroChoseLayer:init()
    

end


function HeroChoseLayer:ctor(param)
    self.kongfuData = param.listData
    self.index = param.index
    self.choseTable = param.choseTable
    -- self.choseResTable = param.choseResTable
    self.updateFunc = param.updateFunc
    self.setUpBottomVisible = param.setUpBottomVisible
    self.removeListener = param.removeListener
    self.curExpValue = 0
            
    --过滤一下，将能够选择的功夫放到列表里
    self.choseAbleData = param.sellAbleData


--    display.addSpriteFramesWithFile("ui/ui_sprite_list.plist", "ui/ui_sprite_list.png")
    --中间的背景
    -- PostNotice(NoticeKey.MAINSCENE_HIDE_BOTTOM_LAYER)

    --上面的条
   local topProxy = CCBProxy:create()
    self.topNode = {}

    local topNode = CCBuilderReaderLoad("skill/skill_select_top.ccbi", topProxy, self.topNode)
    topNode:setPosition(self.topNode["itemBg"]:getContentSize().width * 0.5, display.height)

    local titleSp = display.newSprite("#hero_chose_title.png")
    self.topNode["title"]:setDisplayFrame(titleSp:getDisplayFrame())

    local topBtn = self.topNode["backBtn"]
    topBtn:addHandleOfControlEvent(function(eventName,sender)
                PostNotice(NoticeKey.MAINSCENE_SHOW_BOTTOM_LAYER)
                self.updateFunc()
                self.setUpBottomVisible()
                if self.removeListener ~= nil then
                    self.removeListener()
                end
                self:removeSelf()
                end,
    CCControlEventTouchUpInside)

    --下面的条
    local bottomProxy = CCBProxy:create()
    self.bottomNode = {}

    local bottomNode = CCBuilderReaderLoad("skill/skill_select_bottom.ccbi", bottomProxy, self.bottomNode)
    bottomNode:setPosition(self.bottomNode["itemBg"]:getContentSize().width * 0.5, 0)

    self.bottomNode["choseName"]:setString("选择侠客:")
    -- self.bottomNode[""]




    self.heroNum = self.bottomNode["selectedLabel"]
    self.heroNum:setString(0)

    self.expNum = self.bottomNode["expNumLabel"]
    self.expNum:setString(0)

    local confirmBtn = self.bottomNode["confirmBtn"]
    confirmBtn:addHandleOfControlEvent(function(eventName,sender)
                PostNotice(NoticeKey.MAINSCENE_SHOW_BOTTOM_LAYER)
                self.setUpBottomVisible()
                self.updateFunc()
                if self.removeListener ~= nil then
                    self.removeListener()
                end
                self:removeSelf()
                end,
    CCControlEventTouchUpInside)

    self.behBg = display.newScale9Sprite("jpg_bg/list_bg.png", x, y, CCSizeMake(display.width, display.height-self.topNode["itemBg"]:getContentSize().height-self.bottomNode["itemBg"]:getContentSize().height))
    self.behBg:setPosition(display.width/2,self.bottomNode["itemBg"]:getContentSize().height  )
    self:addChild(self.behBg)
    

    self.bg = display.newScale9Sprite("jpg_bg/list_bg.png", x, y, CCSizeMake(display.width, display.height-self.topNode["itemBg"]:getContentSize().height-self.bottomNode["itemBg"]:getContentSize().height))
    self.bg:setPosition(display.width/2,self.bottomNode["itemBg"]:getContentSize().height + self.bg:getContentSize().height/2 )
    self:addChild(self.bg)
    self:addChild(topNode)
    self:addChild(bottomNode)

    for i = 1,#self.choseTable do
        local resId = self.choseAbleData[self.choseTable[i]]["resId"]
        self.curExpValue = self.curExpValue + ResMgr.getCardData(resId)["exp"]
    end

    self.heroNum:setString(#self.choseTable)
    self.expNum:setString(self.curExpValue)

    local function choseFunc(param)
        -- local resId = param.resId
        local cellIndex = param.cellIndex
        --创建武学精炼界面
        if param.op == 1 then --op是1的时候为增加 ，为2的时候是减
            if #self.choseTable <5 then
                --
                self.choseTable[#self.choseTable + 1] = param.cellIndex
                -- self.choseResTable[#self.choseResTable + 1] = param.resId
                local resId = self.choseAbleData[param.cellIndex]["resId"]
                self.curExpValue = self.curExpValue + ResMgr.getCardData(resId)["exp"]

                self.heroNum:setString(#self.choseTable)
                self.expNum:setString(self.curExpValue)
                return true
            else
                show_tip_label("强化槽已满")
                
                return false    
            end
        else
            if #self.choseTable > 0 then
                for i = 1,#self.choseTable do 
                    if self.choseTable[i] == param.cellIndex then
                        table.remove(self.choseTable,i)
                        -- table.remove(self.choseResTable,i)
                    end
                end
                local resId = self.choseAbleData[param.cellIndex]["resId"]
                self.curExpValue = self.curExpValue - ResMgr.getCardData(resId)["exp"]--param.exp
            else
                print("不能少于0个")
            end
            self.heroNum:setString(#self.choseTable)
            self.expNum:setString(self.curExpValue)
        end
       print("heheeh "..#self.choseTable)
        
    end

    local function createFunc(idx)
        local item = require("game.Hero.HeroChoseCell").new()
        return item:create({
            id       = idx + 1,
            viewSize = CCSizeMake(self.bg:getContentSize().width, self.bg:getContentSize().height),
            list     = self.choseAbleData,  
            choseTable = self.choseTable,
            choseFunc = choseFunc         
            })
    end

    local function refreshFunc(cell,idx)
        cell:refresh(idx + 1)
    end



    self.kongFuList = require("utility.TableViewExt").new({
        size        = CCSizeMake(self.bg:getContentSize().width, self.bg:getContentSize().height),-- numBg:getContentSize().height - 20),
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum   = #self.choseAbleData,--self.kongfuData["1"],
        cellSize    = require("game.Hero.HeroChoseCell").new():getContentSize(),
                       
    })
    -- self.kongFuList:setPosition(-self:getContentSize().width / 2, -self:getContentSize().height / 2 + self:getContentSize().height * (1.4 / 12))
    self.bg:addChild(self.kongFuList)

  
end


return HeroChoseLayer