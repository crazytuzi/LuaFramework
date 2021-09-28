Role = class("Role")
Role.__index = Role


local scale_Hero = 1
local scale_Boss = 2

local speed_Hero = 300

local Image_Background  --地图背景
local Image_Floor --地图
local border_Left  --左移动边界
local border_Right  --右移动边界

local cursor --光标
local gogogo --gogogo动画

ROLETYPE =  --角色类型
{
	ME = 0,
	BOSS = 1,
	OTHERS = 2,
}

local function setCursor(tbData)
	if not cursor then
		return 
	end
	
	cursor:setVisible(tbData.bVisible)
	if tbData.pos then
		cursor:setPosition(tbData.pos)
	end
end

function Role:static_init(background, floor, borderLeft, borderRight)
	Image_Background = background or Image_Background
	Image_Floor = floor or Image_Floor
	border_Left = borderLeft or border_Left
	border_Right = borderRight or border_Right

	--光标
	local userAnimation
	if not cursor then
		cursor, userAnimation = g_CreateCoCosAnimationWithCallBacks("DestinationArrow", nil, nil, 5, nil, nil, false)
		userAnimation:playWithIndex(0)
		cursor:setVisible(false)
		cursor:setZOrder(INT_MAX)
		Image_Floor:addNode(cursor)
		g_FormMsgSystem:RegisterFormMsg(FormMsg_Movement_Cursor, setCursor)
	end

	if not gogogo then
		gogogo, userAnimation = g_CreateCoCosAnimationWithCallBacks("GOGOGO", nil, nil, 5, nil, nil, false)
		userAnimation:playWithIndex(0)
		gogogo:setPosition(CCPoint(1080, 440))
		gogogo:setZOrder(INT_MAX)
		Image_Floor:getParent():addNode(gogogo)
		g_FormMsgSystem:RegisterFormMsg(FormMsg_Movement_Cursor, setCursor)
	end
	gogogo:setVisible(true)
end

function Role:static_destroy()
	if cursor then
		cursor:removeFromParentAndCleanup(true)
	end
	if gogogo then
		gogogo:removeFromParentAndCleanup(true)
	end
	cursor = nil
	gogogo = nil
end

function Role:getPosition()
	return self.Panel_Player:getPosition()
end

function Role:setPosition(pos)
	if self.Panel_Player and self.Panel_Player:isExsit() then

		self.Panel_Player:setPosition(pos)
		self.Panel_Player:setZOrder(640 - pos.y)
		if ROLETYPE.ME == self.roleType then
			if pos.x < border_Left then
				Image_Background:setPosition(CCPoint(0, 0))
				Image_Floor:setPosition(CCPoint(0, 0))
			elseif pos.x > border_Right then
				Image_Background:setPosition(CCPoint(border_Right - border_Left, 0))
				Image_Floor:setPosition(CCPoint(border_Right - border_Left, 0))
			else
				Image_Background:setPosition(CCPoint(pos.x - border_Left, 0))
				Image_Floor:setPosition(CCPoint(pos.x - border_Left, 0))
			end
		end
	end
end

function Role:getPositionX()
	return self.Panel_Player:getPositionX()
end

function Role:setPositionX(x)
	self.Panel_Player:setPositionX(x)
end

function Role:getPositionY()
	return self.Panel_Player:getPositionY()
end

function Role:setPositionY(y)
	self.Panel_Player:setPositionY(y)
end

function Role:getDestination()
	return self.pos_Dest
end

function Role:setDestination(pos)
	self.pos_Dest = pos
end

function Role:setDirection(bFlag)
	if bFlag then
		self.skeleton:setScaleX(1)
		self.Image_Card:setPosition(ccp(self.CSV_CardBase.Pos_X, self.CSV_CardBase.Pos_Y))
		self.Label_Name:setPosition(ccp(self.CSV_CardBase.HPBarX, self.CSV_CardBase.HPBarY))
	else
		self.skeleton:setScaleX(-1)
		self.Image_Card:setPosition(ccp(-self.CSV_CardBase.Pos_X, self.CSV_CardBase.Pos_Y))
		self.Label_Name:setPosition(ccp(-self.CSV_CardBase.HPBarX, self.CSV_CardBase.HPBarY))
	end
	
end

function Role:setVisible(bFlag)
	self.Panel_Player:setVisible(bFlag)
end


function Role:ctor(Panel_Player, nCardID, szName, roleType)
	if not Panel_Player then
		return
	end
	
	local CSV_CardBase
	if ROLETYPE.BOSS == roleType then
		CSV_CardBase = g_DataMgr:getMonsterBaseCsv(nCardID)
	else
		CSV_CardBase = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("CardBase", nCardID, 1)
	end

	local Image_Card = tolua.cast(Panel_Player:getChildByName("Image_Card"),"ImageView")
	Image_Card:removeAllNodes()
	Image_Card:loadTexture(getUIImg("Blank"))
	Image_Card:setScale(0.6)
	Image_Card:setAnchorPoint(ccp(0.5,0))
	Image_Card:setPosition(ccp(CSV_CardBase.Pos_X,CSV_CardBase.Pos_Y))

	local Image_Shadow = tolua.cast(Panel_Player:getChildByName("Image_Shadow"),"ImageView")
	Image_Shadow:loadTexture(getUIImg("Shadow"))
	Image_Shadow:setPosition(ccp(0,0))


	local Label_Name = tolua.cast(Panel_Player:getChildByName("Label_Name"),"Label")
	Label_Name:setText(szName)
	Label_Name:setPosition(ccp(CSV_CardBase.HPBarX, CSV_CardBase.HPBarY))
		
	if ROLETYPE.OTHERS == roleType then
		self.skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, scale_Hero, true)
	elseif ROLETYPE.BOSS == roleType then
		local size = Image_Shadow:getSize()
		Image_Shadow:ignoreContentAdaptWithSize(false)
		Image_Shadow:setSize(CCSize(size.width * scale_Boss, size.height * scale_Boss))
		self.skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, scale_Boss)
		Label_Name:setVisible(false)
	elseif ROLETYPE.ME == roleType then
		self.skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, scale_Hero, true)
		self.nTimeID_Move = g_Timer:pushLoopTimer(0, handler(self,self.updatePos))
	end

	--设置人物层次
	self.nTimeID_ZOrder = g_Timer:pushLoopTimer(0, handler(self, self.updateZOrder))
	
	g_runSpineAnimation(self.skeleton, "idle", true)
	Image_Card:addNode(self.skeleton)

	self.Image_Shadow = Image_Shadow
	self.Label_Name = Label_Name
	self.Image_Card = Image_Card
	self.Panel_Player = Panel_Player
	self.roleType = roleType
	self.CSV_CardBase = CSV_CardBase
end

function Role:destroy()
	g_Timer:destroyTimerByID(self.nTimeID_Move)
	self.nTimeID_Move = nil
	g_Timer:destroyTimerByID(self.nTimeID_ZOrder)
	self.nTimeID_ZOrder = nil
	if self.Panel_Player and self.Panel_Player:isExsit() and ROLETYPE.ME ~= self.roleType then
		self.Panel_Player:removeFromParentAndCleanup(true)
	end
end

function Role:addParent(parent)
	parent:addChild(self.Panel_Player)
end



function Role:moveto(x, y, callBack)
	if self.Panel_Player and self.Panel_Player:isExsit() then

		self:run(true)
		local pos = self.Panel_Player:getPosition()
		self:setDirection(x >= pos.x)
		self:setDestination(CCPoint(x, y))

		if ROLETYPE.ME ~= self.roleType then
			self.Panel_Player:stopAllActions()
			local array = CCArray:create()
			local nDistance = math.sqrt((x - pos.x)*(x - pos.x) + (y - pos.y)*(y - pos.y))
			local moveto = CCMoveTo:create(nDistance / speed_Hero, ccp(x, y))
			array:addObject(moveto)	
			array:addObject(CCCallFuncN:create(function () 
				self:run(false)
				if callBack then
					callBack()
				end
			end))
			local action = CCSequence:create(array)
			self.Panel_Player:runAction(action)
		end
	end
end

function Role:run(bRun)
	if self.bRun == bRun then
		return
	end
	self.bRun = bRun
	local szName = "idle"
	if bRun then
		if ROLETYPE.BOSS == self.roleType then
			szName = "walk"
		else
			szName = "run"
		end
	else
		if ROLETYPE.ME == self.roleType then
			g_FormMsgSystem:PostFormMsg(FormMsg_Movement_Cursor, {bVisible = false} )
		end
	end
	self.skeleton:setAnimation(0, szName, true)
end

function Role:getBoundingBox()
	local size = self.Image_Shadow:getSize()
	local origin = self:getPosition()
	origin.x = origin.x - size.width / 2
	origin.y = origin.y - size.height / 2
	return CCRect(origin.x, origin.y, size.width, size.height)
end

function Role:checkCollision(wbHero)
	return self:getBoundingBox():intersectsRect(wbHero:getBoundingBox())
end


pszBlackWhiteFSH =
[[
	#ifdef GL_ES                                
	precision mediump float;                    
	#endif                                      
	uniform sampler2D u_texture;                
	varying vec2 v_texCoord;                    
	varying vec4 v_fragmentColor;               
	void main(void)                              
	{                                           
	 // Convert to greyscale using NTSC weightings               
		vec4 col = texture2D(u_texture, v_texCoord);                
		float grey = dot(col.rgb, vec3(0.5, 0.5, 0.5));       
		gl_FragColor = vec4(grey / 2.0, grey / 2.0, grey / 2.0, col.a / 2.0);               
	}                                           

]]

function Role:dead(bFlag)
	if bFlag then
		g_setImgShader(self.skeleton, pszBlackWhiteFSH)
	else
		self.skeleton:setShaderProgram("ShaderPositionTextureColor")
	end
end

function Role:updateZOrder()
	if self.bRun then
		local posY = self:getPositionY()
		self.Panel_Player:setZOrder(640 - posY)
	end
end

--自己的走动
function Role:updatePos(fDeltaTime)
	local wbHero_Boss = g_RoleSystem:getBoss()
	if wbHero_Boss then
		if self:checkCollision(wbHero_Boss) then
			self:run(false)
			g_RoleSystem:requestAttack()
			Image_Floor:setTouchEnabled(false)
		end
	end
	if self.bRun then
		local pos_Now = self:getPosition()

		if g_RoleSystem:getAutoFight() then
			self.pos_Dest = g_RoleSystem:getBossDestination() or self.pos_Dest
		end
		self.pos_Dest.x =  math.min(self.pos_Dest.x, g_RoleSystem:getBlockPosX(self.pos_Dest.y))

		--记录上次目的地, 判断是否向服务器发移动请求
		self.pos_Dest_Last = self.pos_Dest_Last or CCPoint(320 , 200)
		if not self.pos_Dest_Last:equals(self.pos_Dest) then
			self.pos_Dest_Last = CCPoint(self.pos_Dest.x, self.pos_Dest.y)
			g_RoleSystem:requestMove(pos_Now, self.pos_Dest)
		end
		local nDistance = math.sqrt((self.pos_Dest.x - pos_Now.x)*(self.pos_Dest.x - pos_Now.x) + (self.pos_Dest.y - pos_Now.y)*(self.pos_Dest.y - pos_Now.y))
		if nDistance == 0 then
			if not g_RoleSystem:getAutoFight() then
				self:run(false)
			end
			return
		end
		local nMoveDistance = math.min(speed_Hero * fDeltaTime, nDistance)
		local nMove_X = nMoveDistance * (self.pos_Dest.x - pos_Now.x) / nDistance
		local nMove_Y = nMoveDistance * (self.pos_Dest.y - pos_Now.y) / nDistance
		if pos_Now.x > border_Left and pos_Now.x < border_Right then
			local posX = Image_Floor:getPositionX() - nMove_X
			posX = math.max(math.min(posX, 0), -border_Right + 640)
			Image_Background:setPositionX(posX * 0.8)
			Image_Floor:setPositionX(posX)
		end
		local pos_X = self:getPositionX() + nMove_X
		if pos_X < border_Right then
			gogogo:setVisible(true)
		else
			gogogo:setVisible(false)
		end
		self:setPositionX(pos_X)
		self:setPositionY(self:getPositionY() + nMove_Y)
	end
end
	
