local JieYi = class("JieYi", function () return cc.Layer:create() end )

function JieYi:ctor(theIndex)
    -- init jieyi layer here
    --local btnName = {"jyJLP","jySkill"}

    local func1 = g_msgHandlerInst:getMsgHandler(SWORN_SC_DO_ACTION_RET)
    local endFunc = function ()    
        g_msgHandlerInst:registerMsgHandler( SWORN_SC_DO_ACTION_RET , func1 )
    end

    local bg,closeBtn =  createBgSprite(self,nil,nil,true,endFunc)
    --local tab_control = {}
	local posx,posy =600,605
    local spriteName = {}
    local select_index = 0
    local subLayers =  self:addSubLayers(bg)
	
    local onMenuClick = function (index)
        if select_index == index then
            return
        end
        select_index = index
        for k,v in pairs(subLayers) do
            v:setVisible(false)
        end
        subLayers[select_index]:setVisible(true)
    end

	-- local tempTitle = 2
	-- for i=1,tempTitle do 
	-- 	tab_control[i] = {}
	-- 	tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/1.png","res/component/TabControl/2.png")
	-- 	tab_control[i].menu_item:setPosition(cc.p(posx,posy))
	-- 	spriteName[i] = createLabel(tab_control[i].menu_item,game.getStrByKey(btnName[i]),cc.p(tab_control[i].menu_item:getContentSize().width/2,tab_control[i].menu_item:getContentSize().height/2),cc.p(0.5,0.5),24,nil,nil,nil,MColor.lable_black,i)
	-- 	tab_control[i].callback = onMenuClick
	-- 	posx = posx + 155
	-- end

	-- self.tab_control = tab_control
 --    local curIndex = theIndex or 1
	-- G_TUTO_NODE:setTouchNode(tab_control[2].menu_item, TOUCH_SKILL_SET_TAB)
	-- creatTabControlMenu(bg,tab_control,curIndex)
 --    onMenuClick(curIndex)
    local tab_jyJLP = game.getStrByKey("jyJLP")
    local tab_jySkill = game.getStrByKey("jySkill")

    local tabs = {}
    tabs[#tabs+1] = tab_jyJLP
    tabs[#tabs+1] = tab_jySkill

    local TabControl = Mnode.createTabControl(
    {
        src = {"res/common/TabControl/1.png", "res/common/TabControl/2.png"},
        size = 22,
        titles = tabs,
        margins = 2,
        ori = "|",
        align = "r",
        side_title = true,
        cb = function(node, tag)
            onMenuClick(tag)
            local title_label = bg:getChildByTag(12580)
            if title_label then title_label:setString(tabs[tag]) end
        end,
        selected = theIndex or 1,
    })

    Mnode.addChild(
    {
        parent = bg,
        child = TabControl,
        anchor = cc.p(0, 0.0),
        pos = cc.p(931, 460),
        zOrder = 200,
    })
    G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(2), TOUCH_SKILL_SET_TAB)
    --subLayers = self:addSubLayers()

	SwallowTouches(self)
end

function JieYi:addSubLayers(bg)
    local subLayers = {}
    subLayers[1] = require("src/layers/jieyi/JieYiJLPLayer").new(self)
    subLayers[2] = require("src/layers/jieyi/JieYiSkillLayer").new()
    for k,v in pairs(subLayers) do
        v:setPosition(cc.p(0,0))
        v:setVisible(false)
        bg:addChild(v)
    end
    return subLayers
end

return JieYi