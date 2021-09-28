
local ExerciseDamgeShow = class("ExerciseDamgeShow", function() return cc.Node:create() end)
local commConst = require("src/config/CommDef");

function ExerciseDamgeShow:ctor(parent)
	if parent then
		self.parent = parent
		parent:addChild(self)
	end
	

    local menu, exit_btn = require("src/component/button/MenuButton").new(
    {
	    parent = self,
	    pos = cc.p(display.width-69, display.height-100),
        src = {"res/component/button/1.png", "res/component/button/1_sel.png", "res/component/button/1_gray.png"},
	    label = {
		    src = game.getStrByKey("exit"),
		    size = 22,
		    color = MColor.lable_yellow,
	    },
	    cb = function(tag, node)
        	g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_EXITCOPY,"ExitCopyProtocol", {})
			addNetLoading(COPY_CS_EXITCOPY,FRAME_SC_ENTITY_ENTER)
	    end,
    })
    self:registerScriptHandler(function(event)
		if event == "enter" then
			-- if G_MAINSCENE.taskBaseNode then
			-- 	G_MAINSCENE.taskBaseNode:setVisible(false)
			-- end
		elseif event == "exit" then
			
		end
	end)
	local height = display.height - 212

	local posYOffset = 30
	local bg = createScale9Sprite(self, "res/fb/multiple/bg.png", cc.p(display.width - 10, height), cc.size(257, 172),cc.p(1, 0.5), nil, nil, 101)	
	createLabel(bg,"伤害统计", cc.p(bg:getContentSize().width/2, bg:getContentSize().height-12), cc.p(0.5, 0.5), 22, true,nil,nil,MColor.lable_yellow,11)
	self.bg=bg
	Mnode.listenTouchEvent(
	{
		node = self.bg,
		swallow = true,
		begin = function(touch, event)
			print("touch")
			local touchOutside = Mnode.isTouchInNodeAABB(self.bg, touch)
			return touchOutside
		end,
	})
	local switchShowModeFunc = function()
		if self.bgIsShow then
			self.swithShowModeBtn:setTexture("res/mainui/anotherbtns/shrink.png")
			-- bg:runAction(cc.MoveTo:create(0.2, cc.p(- bg:getContentSize().width + 5, height)))
			bg:runAction(cc.MoveBy:create(0.2, cc.p(bg:getContentSize().width + 10, 0)))
		else
			-- bg:runAction(cc.MoveTo:create(0.2, cc.p(0, height)))
			bg:runAction(cc.MoveBy:create(0.2, cc.p(-bg:getContentSize().width - 10, 0)))
			self.swithShowModeBtn:setTexture("res/mainui/anotherbtns/spread.png")
		end
		self.bgIsShow = not self.bgIsShow
	end
	self.swithShowModeBtn = createTouchItem(bg, "res/mainui/anotherbtns/spread.png", cc.p( -50, 110), switchShowModeFunc)
	self.swithShowModeBtn:setAnchorPoint(cc.p(0, 1))
	self.bgIsShow = true

	local damageData={
		id=0,
		avoid=0,
		skill_id=1006,
		real_hurt=999,
		skill_hurt=99999,
		add_hurt=666,
		def_avoid=333,
		buff_id=0,
	}
	
	local scrollView1 = cc.ScrollView:create()
    local width , height = self.bg:getContentSize().width , self.bg:getContentSize().height-25
    scrollView1:setViewSize(cc.size( width , height ))
    scrollView1:setPosition(cc.p(0, 0))
    scrollView1:setAnchorPoint(cc.p(0,0))
    scrollView1:ignoreAnchorPointForPosition(false)
    scrollView1:setContainer( node )
    scrollView1:updateInset()

    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    scrollView1:setDelegate()
	scrollView1:setTouchEnabled(true)
	self.bg:addChild(scrollView1)
	self.scrollView=scrollView1
	
	self.contentNode=cc.Node:create()
	self.contentNode:setPosition(cc.p(15, self.bg:getContentSize().height-35))
	scrollView1:addChild(self.contentNode)

	--self:showDamge(damageData)
end

function ExerciseDamgeShow:showDamge(data)
	self.contentNode:removeAllChildren()
	local nodes={}
	local totalHeight=0
	local marginv=6
	local attack="攻击"
	if data.crit and data.crit==true then
		attack="暴击"
	end
	print("userInfo.currRoleStaticId ="..userInfo.currRoleStaticId )
	if data.avoid ==true then
		print("本次攻击被闪避")
		local richText = require("src/RichText").new(self.contentNode, cc.p(0, 0), cc.size(self.bg:getContentSize().width-5, 30), cc.p(0, 1), 19, 18, MColor.lable_yellow)
	    richText:addText("本次攻击被闪避")
	    richText:format()
	    totalHeight=totalHeight+richText:getContentSize().height+marginv
	else
		if data.id~=userInfo.currRoleStaticId then
			local richText = require("src/RichText").new(self.contentNode, cc.p(0, 0), cc.size(self.bg:getContentSize().width-5, 30), cc.p(0, 1), 19, 18, MColor.lable_yellow)
		    richText:addText("本次"..attack.."最终造成 ^c(green)"..data.real_hurt.."^ 点伤害")
		    richText:format()
		    totalHeight=totalHeight+richText:getContentSize().height+marginv
		    
		    richText = require("src/RichText").new(self.contentNode, cc.p(0, -totalHeight), cc.size(self.bg:getContentSize().width-5, 30), cc.p(0, 1), 19, 18, MColor.lable_yellow)
		    richText:addText("◆"..getConfigItemByKey("SkillCfg", "skillID",data.skill_id,"name").."造成 ^c(green)"..data.skill_hurt.."^ 点伤害")
		    richText:format()
			totalHeight=totalHeight+richText:getContentSize().height+marginv
		    local skillHurtType=getConfigItemByKey("SkillCfg","skillID",data.skill_id,"skillHurtType")
			local type=  "魔法"
			if skillHurtType==1 then
				type="物理"
			end
			richText = require("src/RichText").new(self.contentNode, cc.p(0, -totalHeight), cc.size(self.bg:getContentSize().width-5, 30), cc.p(0, 1), 19, 18, MColor.lable_yellow)
		    richText:addText("◆秘籍技能附加造成 ^c(green)"..data.add_hurt.."^ 点伤害")
		    richText:format()
			totalHeight=totalHeight+richText:getContentSize().height+marginv
		    
			richText = require("src/RichText").new(self.contentNode, cc.p(0, -totalHeight), cc.size(self.bg:getContentSize().width-5, 30), cc.p(0, 1), 19, 18, MColor.lable_yellow)
		    richText:addText("◆"..type.."防御减免 ^c(green)"..data.def_avoid.."^ 点伤害")
		    richText:format()
			totalHeight=totalHeight+richText:getContentSize().height+marginv

		    richText = require("src/RichText").new(self.contentNode, cc.p(0, -totalHeight), cc.size(self.bg:getContentSize().width-5, 30), cc.p(0, 1), 19, 18, MColor.lable_yellow)
		    richText:addText("◆经过穿透后，敌人剩余减免类属性共减免 ^c(green)"..(data.add_hurt+data.skill_hurt-data.real_hurt-data.def_avoid).."^ 点伤害")
		    richText:format()
		    totalHeight=totalHeight+richText:getContentSize().height+marginv
		else
			local richText = require("src/RichText").new(self.contentNode, cc.p(0, 0), cc.size(self.bg:getContentSize().width-5, 30), cc.p(0, 1), 19, 18, MColor.lable_yellow)
		    richText:addText("本次最终受到 ^c(green)"..data.real_hurt.."^ 点伤害")
		    richText:format()
		    totalHeight=totalHeight+richText:getContentSize().height+marginv

		    richText = require("src/RichText").new(self.contentNode, cc.p(0, -totalHeight), cc.size(self.bg:getContentSize().width-5, 30), cc.p(0, 1), 19, 18, MColor.lable_yellow)
		    richText:addText("◆敌人"..attack.."造成 ^c(green)"..data.skill_hurt.."^ 点伤害")
		    richText:format()
			totalHeight=totalHeight+richText:getContentSize().height+marginv

			richText = require("src/RichText").new(self.contentNode, cc.p(0, -totalHeight), cc.size(self.bg:getContentSize().width-5, 30), cc.p(0, 1), 19, 18, MColor.lable_yellow)
		    richText:addText("◆物理防御减免 ^c(green)"..data.def_avoid.."^ 点伤害")
		    richText:format()
			totalHeight=totalHeight+richText:getContentSize().height+marginv

			richText = require("src/RichText").new(self.contentNode, cc.p(0, -totalHeight), cc.size(self.bg:getContentSize().width-5, 30), cc.p(0, 1), 19, 18, MColor.lable_yellow)
		    richText:addText("◆减免类属性抵挡了 ^c(green)"..data.spec_avoid.."^ 点伤害")
		    richText:format()
			totalHeight=totalHeight+richText:getContentSize().height+marginv
		end
	end
    local contentHeight=math.max((self.bg:getContentSize().height-30),totalHeight)
	self.scrollView:setContentSize(cc.size(self.bg:getContentSize().width, contentHeight))
    self.contentNode:setPosition(cc.p(5, contentHeight-5))
    self.scrollView:setContentOffset( cc.p( 0 ,0 ) )
    if contentHeight>(self.bg:getContentSize().height-25) then
    	self.scrollView:setContentOffset( cc.p( 0 ,   (self.bg:getContentSize().height-30)-contentHeight ) )
    end
end




--------------
return ExerciseDamgeShow
