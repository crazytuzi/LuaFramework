GUIPixesObject = {}

local BUBBLE_FONT_SIZE = 24
local MAX_SINGLE_LINE = 12

function GUIPixesObject.getPixesGhost(id)
	local GUIPixesObject = CCGhostManager:getPixesGhostByID(id)
	return GUIPixesObject
end

function GUIPixesObject.addTypewritter(ghost,str)
	-- local baseSprite = ghost:getSprite()
	-- if not GameUtilSenior.isObjectExist(baseSprite) then return end
	-- if baseSprite:getChildByName("img_bubble") then return end

	-- local length = string.utf8len(str)
	-- local typer
	-- local img_bubble = ccui.ImageView:create("img_talk_bubble", ccui.TextureResType.plistType)
	-- local img_bubbleArrow

	-- local msgLength = GameUtilSenior.getColorJsonLength(str)
	-- local lblLine = math.ceil(msgLength/MAX_SINGLE_LINE)
	-- local maxHeight = lblLine*BUBBLE_FONT_SIZE+20--20是上下两个圆角
	-- local maxWidth = (lblLine == 1 and BUBBLE_FONT_SIZE*msgLength or BUBBLE_FONT_SIZE*MAX_SINGLE_LINE) + 20

	-- local fd = ghost:getDressFrame(0)
	-- if fd then
	-- 	img_bubble:setScale9Enabled(true)
	-- 	img_bubble:setCapInsets(cc.rect(10,10,10,10))
	-- 	img_bubble:addTo(baseSprite):align(display.BOTTOM_CENTER, 24, -fd:GetValue(0,0,5)+35):setName("img_bubble")

	-- 	img_bubbleArrow = ccui.ImageView:create("img_talk_bubble_arrow", ccui.TextureResType.plistType):addTo(img_bubble):align(display.CENTER_TOP)
	-- 	img_bubbleArrow:setName("img_bubbleArrow")

	-- 	typer = cc.GuiTextTyper:create(BUBBLE_FONT_SIZE*MAX_SINGLE_LINE, 0, BUBBLE_FONT_SIZE):addTo(img_bubble):align(display.CENTER)
	-- 	typer:setName("typer")

	-- 	typer:setTextTyper(str, BUBBLE_FONT_SIZE, cc.c3b(0,0,0))

	-- 	if maxHeight < 30 then maxHeight = 30 end
	-- 	if maxWidth < 30 then maxWidth = 30 end
		
	-- 	img_bubble:size(maxWidth, maxHeight)
	-- 	img_bubbleArrow:pos(maxWidth/2, 1)

	-- 	typer:pos(10, (maxHeight-10)):runScheduler(length*50)
	-- end

	-- local time = length*100 > 2000 and length*100 or 2000
	-- img_bubble:runAction(
	-- 	cca.seq({
	-- 		cca.delay(time/1000),
	-- 		cca.removeSelf()
	-- 	}))
end

return GUIPixesObject