local GDivSkill = {}
local var = {}
local STATE = {
	IDLE	= 0,STAND = 0,
	WALK	= 1,
	RUN		= 2,
	PREPARE = 3,
	ATTACK	= 4,
	SKILL	= 5,
	INJURY	= 6,
	DIE		= 7,
	DAZUO	= 8,
	CAIKUANG= 9,
	MDIE 	= 10,
	MWALK	= 11,
	MJUMP	= 12,
	MRUN 	= 13,
}

local delayPerUnit = 1/30
local RES_PATH={[0]="cloth/",[1]="weapon/",[2]="mount/",[3]="wing/",[4]="effect/",[5]="fashion/",[6]="fabao/"};
--跑步：16/30秒内跑两格
local speed = {x = 66, y=44}
local moveTime = function(pos1,pos2) return 16/30*(math.abs(pos1.x-pos2.x)/(speed.x*2) + math.abs(pos1.y-pos2.y)/(2*speed.y)) end
local head_key ={"new_main_ui_head.png","head_fzs","head_mfs","head_ffs","head_mds","head_fds"}
local zorderTable = {
	{"shadow", "weapon","cloth","wing","skill"},
	{"shadow", "cloth","weapon","wing","skill"},
	{"shadow", "cloth","weapon","wing","skill"},
	{"shadow", "wing","cloth","weapon","skill"},
	{"shadow", "wing","cloth","weapon","skill"},
	{"shadow", "wing","cloth","weapon","skill"},
	{"shadow", "cloth","weapon","wing","skill"},
	{"shadow", "cloth","weapon","wing","skill"},
};

local FRAME_FILE={4,8,8,1,6,7,2,4};--图片张数
local FRAME_COUNT={48,8,16,1,11,17,4,8};--动作帧数
--每张图片对应index的图片的帧数
local FRAME_INDEX={
	[0]={12,12,12,12,0,0,0,0,0,0},--待机 48帧
	[1]={2,2,2,2,2,2,2,2,0,0},--行走 16帧
	[2]={2,2,2,2,2,2,2,2,0,0},--跑步 16帧
	[3]={1,0,0,0,0,0,0,0,0,0},--备战 1帧 从放技能开始2秒 动作结束显示备战帧，之后显示待机（放技能动作结束到下一个技能之间显示备战）
	[4]={2,2,2,2,1,2,0,0,0,0},--攻击 11帧 6张图
	[5]={2,2,2,2,3,4,2,0,0,0},--放技能 17帧 7张图
	[6]={2,2,0,0,0,0,0,0,0,0},--受伤 4帧
	[7]={2,2,2,2,0,0,0,0,0,0},--死亡 8帧
};
--m_skillsDesp.mEffectType
local EFFECT_TYPE={
	Effect_Type_MCMapPosition=5,
	Effect_Type_MCOwnerDir=10,--8方向普通攻击
	--Effect_Type_MCAirPosition,
	Effect_Type_MCOwnerFlyTarget=12,--施法,飞行,击中
	Effect_Type_MCFireWall=13,--火墙
	Effect_Type_MCHellFire=14,--地狱火
	Effect_Type_MCWaitFlyTarget=15,--飞行,击中
	Effect_Type_MCWaitTarget=16,--击中
	Effect_Type_MCOwnerPosition=17,--施法,击中位置
	Effect_Type_MCOwnerTarget=18,--施法,击中目标
	Effect_Type_MCWaitFlying=19,--飞行
	Effect_Type_MCOwnerRotate=20,--自身根据方向旋转
	Effect_Type_MCOwnerNoDir=21,--自身不区分方向
	Effect_Type_MCYeManChongZhuang=22,--野蛮冲撞
	--Effect_Type_WaitOwner,
	--Effect_Type_Jump,
};
local mapSize = cc.size(512*5+45,512*5+45)
local mapOffset = cc.p(-730,640)
function printKey( t,value )
	local key = {}
	for k,v in pairs(t) do
		if v==value then table.insert(key,k) end
	end
	print("--key--",unpack(key),"--value--",value)
end

local function logicPosToPixesPos(x,y)
	return NetCC:logicPosToPixesPos(x,y)
end
local function pixesPosToLogicPos(x,y)
	return NetCC:pixesPosToLogicPos(x,y)
end
local function newSkillAnimateWithFrameData(effectResId,dir,finishCallBack,startDownloadCallBack)
	local frameData = GameSkill.getRate(effectResId)
	local soundId,playFrameIndex = GameSkill.getSkillSound(effectResId)
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,effectResId,dir,4,false,false,0,function(animate,shouldDownload)
		local newAnimate = animate
		local hideTime = 0
		print("oldskill-----",effectResId)
		if animate and frameData then
			local animation = animate:getAnimation()
			if animation then
				local animationFrames = animation:getFrames()
				local newFrames = {}
				local spriteFrameNum,framesNum = frameData[1],frameData[2]
				-- print("oldskill-----",#animationFrames,spriteFrameNum,framesNum, animate:getAnimation():getDuration())
				local j,preIdx = 0
				for i=3,2+framesNum do
					local fidx = frameData[i]+1;
					if fidx>0 then
						if not preIdx then
							preIdx = fidx
						end
						if i == 2+ framesNum then j = j+1 end
						if fidx ~= preIdx or i == 2 + framesNum then
							if animationFrames[preIdx] then
								table.insert(newFrames,animationFrames[preIdx]:setDelayUnits(j))
							else
								print("skillframe is nil",preIdx)
							end
							j = 0
							preIdx = fidx
						end
						j = j + 1
					else
						j=0
						hideTime = hideTime + delayPerUnit --空帧隐藏起来
					end
				end
				local newAnimation = cc.Animation:create(newFrames,delayPerUnit,1)--每帧不一样频率	initWithAnimationFrames同create
				-- print("newskill-----",effectResId,#newFrames,framesNum*delayPerUnit,hideTime+newAnimation:getDuration())
				if newAnimation then
					if hideTime >0 then
						-- print("resId",effectResId,hideTime,newAnimation:getDuration())
						newAnimate = cca.seq({
							cca.hide(),
							cca.delay(hideTime),
							cca.show(),
							cc.Animate:create(newAnimation)
						})
					else
						newAnimate = cc.Animate:create(newAnimation)
					end
				end
			end
			if finishCallBack then
				finishCallBack(newAnimate)
			end
		end
		if soundId>0 and playFrameIndex>0 then
			local m = cca.spawn({
				cca.seq({cca.delay(playFrameIndex*delayPerUnit),cca.cb(function()
					GameMusic.play(string.format("music/%s.mp3",soundId))
				end)}),
				newAnimate
			})
			if finishCallBack then
				finishCallBack(m)
			end
			return m
		else
			if finishCallBack then
				finishCallBack(newAnimate)
			end
			return newAnimate
		end
	end,
	function(animate)
		if startDownloadCallBack then
			startDownloadCallBack()
		end
	end)
end

local function getActionAnimate(effectType,effectResId,state,dir,finishCallBack,startDownloadCallBack)
	assert(effectType,"effectType is nil")
	assert(effectResId,"effectResId is nil")
	assert(state,"state is nil")
	assert(dir,"dir is nil")
	-- state = state or STATE.IDLE
	-- dir = dir or 4
	local frametime = FRAME_INDEX[state]
	local animate = cc.AnimManager:getInstance():getPlistAnimate(effectType,effectResId,dir,1,false,true,state,function(animate,shouldDownload)
							if animate then
								local animation = animate:getAnimation()
								-- print("1-------",RES_PATH[state],effectResId,animate:getAnimation():getDuration())
								if animation then
									local animationFrames = animation:getFrames()
									local newAnimationFrames = {}
									for i,v in ipairs(frametime) do
										if v>0 and animationFrames[i] then
											table.insert(newAnimationFrames,animationFrames[i]:setDelayUnits(v))
										end
									end
									animate = cc.Animate:create(cc.Animation:create(newAnimationFrames,delayPerUnit,1))
									-- print("2-------",RES_PATH[state],effectResId,#animationFrames,#newAnimationFrames,animate:getAnimation():getDuration())
								end
								if finishCallBack then
									finishCallBack(animate,shouldDownload)
								end
								return animate
							else
								print("getActionAnimate failure---",RES_PATH[effectType],effectResId,state,dir)
							end
						end,
						function(animate)
							if startDownloadCallBack then
								startDownloadCallBack()
							end
						end)
	
end

local function cisha(selfnode,target,skillDesp,dir,flip)
	local img_skill = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill:addTo(selfnode):align(display.CENTER, 0, 0):setLocalZOrder(0):setFlippedX(flip)
	local animate = newSkillAnimateWithFrameData(skillDesp.mEffectResID,dir,function(animate,shouldDownload)
		if animate then
			return cc.TargetedAction:create(img_skill,cca.seq({
				animate,
				cca.removeSelf()
			}))
		end
		if shouldDownload==true then
			selfnode:release()
			img_skill:release()
		end
	end,
	function(animate)
		selfnode:retain()
		img_skill:retain()
	end)
end
local function liehuo(selfnode,target,skillDesp,dir,flip)
	local img_skill = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill:addTo(selfnode):align(display.CENTER, 0, 0):setLocalZOrder(0):setFlippedX(flip)
	local animate = newSkillAnimateWithFrameData(skillDesp.mEffectResID,dir)
	if animate then
		return cc.TargetedAction:create(img_skill,cca.seq({
			animate,
			cca.removeSelf()
		}))
	end
end
local function zhuri(selfnode,target,skillDesp,dir,flip)
	local img_skill = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill:addTo(selfnode):align(display.CENTER, 0, 0):setLocalZOrder(0):setFlippedX(flip)
	local animate = newSkillAnimateWithFrameData(skillDesp.mEffectResID,dir)
	if animate then
		return cc.TargetedAction:create(img_skill,cca.seq({
			animate,
			cca.removeSelf()
		}))
	end
end
local function leidian(selfnode,target,skillDesp,dir,flip)
	local img_skill = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill:addTo(selfnode:getParent()):align(display.CENTER, selfnode:getPositionX(),selfnode:getPositionY()):setLocalZOrder(0):setFlippedX(flip)
	local animate1 = newSkillAnimateWithFrameData(skillDesp.mEffectResID,dir)
	local animate2 = newSkillAnimateWithFrameData(skillDesp.mEffectResID+1,dir)
	print(skillDesp.mEffectResID,skillDesp.mEffectResID+1,animate1,animate2)
	if animate1 and animate2 then
		return cc.TargetedAction:create(img_skill,cca.seq({
			animate1,
			cca.place(target:getPositionX(),target:getPositionY()),
			animate2,
			cca.removeSelf()
		}))
	end
end
local function mofadun(selfnode,target,skillDesp,dir,flip)
	---20300
	local img_skill = selfnode:getChildByName("mofadunSprite")
	if not img_skill then
		img_skill = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
		img_skill:addTo(selfnode):setName("mofadunSprite"):align(display.CENTER, 0, 0):setLocalZOrder(0):setFlippedX(flip)
	end
	local animate1 = newSkillAnimateWithFrameData(skillDesp.mEffectResID,dir)
	if animate1 then
		img_skill:stopAllActions()
		img_skill:runAction(cca.loop(animate1))
		local t1 = GameSkill.getSkillTime(skillDesp.mEffectResID)
		return cca.delay(t1)
	end
end
local function huoqiang(selfnode,target,skillDesp,dir,flip)
	local img_skill1 = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill1:addTo(selfnode):align(display.CENTER, 0, 0):setLocalZOrder(4):setFlippedX(flip)

	local skilltarget = {}
	local spd = speed--GameUtilSenior.half(speed)
	local posskilli = {cc.p(-spd.x,0), cc.p(spd.x,0), cc.p(0,spd.y), cc.p(0,-spd.y)}
	local zorder = {0,0,-1,1}
	local postarget = cc.p(target:getPositionX(),target:getPositionY())
	local zordertarget = target:getLocalZOrder()
	for i=1,4 do
		local posi = cc.pAdd(posskilli[i],postarget)
		skilltarget[i] = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
		skilltarget[i]:addTo(target:getParent())
			:align(display.CENTER, posi.x,	posi.y)
			:setLocalZOrder(zordertarget + zorder[i])
			:setFlippedX(flip)
	end
	local animate1 = newSkillAnimateWithFrameData(skillDesp.mEffectResID,dir)
	local animate2 = newSkillAnimateWithFrameData(skillDesp.mEffectResID+1,dir)
	if animate1 and animate2 then
		--火墙身上一个，地上一个持续20秒,同时释放
		return cc.TargetedAction:create(img_skill1,cca.seq({
			cca.cb(function()
				for i=1,4 do
					skilltarget[i]:runAction(cca.seq({cca.rep(animate2:clone(),15), cca.removeSelf()}))--火墙30秒消失
				end
			end),
			animate1,
			cca.removeSelf()
		}))
	end
end
local function zhaogou(selfnode,target,skillDesp,dir,flip)
	local this = selfnode.Instance
	this._dog = Dog:new({
		name = this.name,
		owner = this,
		enemy = this:getEnemy(),
		dir = this.direction,
	})
	this._dog:doAction(STATE.STAND)
	local img_skill = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill:addTo(selfnode):align(display.CENTER, 0, 0):setLocalZOrder(0):setFlippedX(flip)
	local animate2 = newSkillAnimateWithFrameData(skillDesp.mEffectResID,4)--玩家自身技能特效
	if animate2 then
		return cc.TargetedAction:create(img_skill,cca.seq({
			animate2,
			cca.cb(function ()
				this._dog:skill()
			end),
			cca.removeSelf()
		}))
	end
	return nil
end
local function huofu(selfnode,target,skillDesp,dir,flip)
	local img_skill1 = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill1:addTo(selfnode:getParent()):align(display.CENTER, selfnode:getPositionX(),selfnode:getPositionY()):setLocalZOrder(0):setFlippedX(flip)
	local img_skill2 = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill2:addTo(target:getParent()):align(display.CENTER, selfnode:getPositionX(),selfnode:getPositionY()):setLocalZOrder(0):setFlippedX(flip)
	local animate1 = newSkillAnimateWithFrameData(skillDesp.mEffectResID,dir)
	local animate2 = newSkillAnimateWithFrameData(skillDesp.mEffectResID+1,dir)--飞行动作角度自己计算
	local animate3 = newSkillAnimateWithFrameData(skillDesp.mEffectResID+2,dir)
	if animate1 and animate2 and animate3 then
		return cca.spawn({
			cc.TargetedAction:create(img_skill1,cca.seq({
				animate1,
				cca.removeSelf()
				})),
			cc.TargetedAction:create(img_skill2,cca.seq({
				cca.cb(function(tar)
					local r = 90 + math.deg(cc.pToAngleSelf(cc.p(target:getPositionX()-selfnode:getPositionX(),target:getPositionY()-selfnode:getPositionY())));
					tar:setRotation(r);
				end),
				cca.spawn({
					cca.moveTo(10/30,target:getPositionX(),target:getPositionY()),
					animate2
				}),
				cca.cb(function(tar)
					tar:setRotation(0)
				end),
				animate3,
				cca.removeSelf()
				}))
			})
	end
end
local function shengjiashu(selfnode,target,skillDesp,dir,flip)
	local img_skill = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill:addTo(selfnode:getParent()):align(display.CENTER, selfnode:getPositionX(), selfnode:getPositionY()):setLocalZOrder(0):setFlippedX(flip)
	local animate = newSkillAnimateWithFrameData(skillDesp.mEffectResID,dir)
	if animate then
		return cc.TargetedAction:create(img_skill,cca.seq({
			animate,
			cca.removeSelf()
		}))
	end
end
local function qundushu(selfnode,target,skillDesp,dir,flip)
	local img_skill1 = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill1:addTo(selfnode):align(display.CENTER, 0, 0):setLocalZOrder(0):setFlippedX(flip)

	local img_skill2 = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill2:addTo(target):align(display.CENTER, 0, 0):setLocalZOrder(0):setFlippedX(flip)
	
	local animate1 = newSkillAnimateWithFrameData(skillDesp.mEffectResID,2)
	local animate2 = newSkillAnimateWithFrameData(skillDesp.mEffectResID+1,2)
	if animate1 and animate2 then
		return cca.spawn({
			cc.TargetedAction:create(img_skill1,cca.seq({
				animate1,
				cca.removeSelf()
				})),
			cc.TargetedAction:create(img_skill2,cca.seq({
				animate2,
				cca.removeSelf()
				})),
			})
	end
end
local function penhuo(selfnode,target,skillDesp,dir,flip)
	local img_skill = cc.Sprite:create():setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	img_skill:addTo(selfnode):align(display.CENTER, 0, 0):setLocalZOrder(0):setFlippedX(flip)
	local animate = newSkillAnimateWithFrameData(skillDesp.mEffectResID,dir)
	if animate then
		return cc.TargetedAction:create(img_skill,cca.seq({
			animate,
			cca.removeSelf()
		}))
	end
end

local skill = {
	[103] = {name="刺杀剑法",	func = cisha,		effect_type = 10},--ok 10100
	[106] = {name="烈火剑法",	func = liehuo,		effect_type = 10},--ok 10300
	[109] = {name="逐日剑法",	func = zhuri,		effect_type = 10},--ok 10400
	[405] = {name="雷电术",		func = leidian,		effect_type = 18,dir = 4},--ok 20000
	[412] = {name="魔法盾",		func = mofadun,		effect_type = 21,dir = 4},--ok 20300
	[409] = {name="火墙",		func = huoqiang,	effect_type = 13,dir = 4},--ok 20500
	[513] = {name="召唤虎卫",	func = zhaogou,		effect_type = 21},--30700
	[504] = {name="灵魂火符",	func = huofu,		effect_type = 12,dir = 4},--ok 30000,30001,30002
	[508] = {name="圣甲术",		func = shengjiashu,	effect_type = 16,dir = 4},--30600,防
	[503] = {name="群毒术",		func = qundushu,	effect_type = 17,dir = 4},--ok 30200,30201
	[700] = {name="狗喷火",		func = penhuo,		effect_type = 10},--ok30800
	[524] = {name="群体雷电术",		func = huoqiang,	effect_type = 13,dir = 4},--ok 20500
}

function skill:getSkillAction(skillId,selfnode,target,dir)
	if self[skillId] then
		local skillDesp = GameBaseLogic.getSkillDesp(skillId)
		if skillDesp then
			dir = self[skillId].dir or dir
			local isflip = false
			if dir>=5 then
				dir = 8 - dir
				isflip = true
			end
			return self[skillId].func(selfnode,target,skillDesp,dir,isflip)
		end
	end
end

local guardConfig = {
	[1]= {name="护卫1阶",  id=303001, weaponRes=60006,clothRes=20004, },
	[2]= {name="护卫2阶",  id=303002, weaponRes=60007,clothRes=20005, },
	[3]= {name="护卫3阶",  id=303003, weaponRes=60008,clothRes=20006, },
	[4]= {name="护卫4阶",  id=303004, weaponRes=60009,clothRes=20007, },
	[5]= {name="护卫5阶",  id=303005, weaponRes=60010,clothRes=20008, },
	[6]= {name="护卫6阶",  id=303006, weaponRes=60011,clothRes=20009, },
	[7]= {name="护卫7阶",  id=303007, weaponRes=60012,clothRes=20010, },
	[8]= {name="护卫8阶",  id=303008, weaponRes=60013,clothRes=20011, },
	[9]= {name="护卫9阶",  id=303009, weaponRes=60014,clothRes=20012, },
    [10]={name="护卫10阶", id=303010, weaponRes=60015,clothRes=20012, },
}

local player = {
	_avatar,
	_guard,
	_dog,
	name = "",
	job = 0,
	level = 0,
	gender = 0,
	hp = 100,
	MaxHp = 100,
	dc = 0,maxdc = 0,--物攻
	mc = 0,maxmc = 0,--魔攻
	sc = 0,maxsc = 0,--道攻
	ac = 0,maxac = 0,--物防
	mac= 0,maxmac= 0,--魔防
	headLayout,
	enemy,
	clothId,
	weaponId,
	wingId,
	direction = 0,
	skills = {},--id
	guardLv = 1,

	state = 0,--
}

function player:getAvatar()
	if not GameUtilSenior.isObjectExist(self._avatar) then self._avatar = cc.Node:create():hide() end
	self._avatar.Instance = self
	return self._avatar
end
function player:new(...)
	local cls = clone(self)
	cls:ctor(...)
	return cls
end
function player:bindHeadLayout(widget)
	self.headLayout = widget;
	self.headLayout:getWidgetByName("hp"):setProgressTime(0.4)
end
function player:ctor(data)
	if GameUtilSenior.isTable(data) and data.headLayout then
		self:bindHeadLayout(data.headLayout)
	end
	if GameUtilSenior.isTable(data) and GameUtilSenior.isObjectExist(self.headLayout) then
		if data.level then
			self.level = data.level
			self.headLayout:getWidgetByName("lv"):setString(data.level) 
		end
		if data.job and data.gender then
			self.job = data.job
			self.gender = data.gender
			local id = (self.job-100) * 2 + self.gender - 199
			self.headLayout:getWidgetByName("head"):loadTexture(head_key[id],ccui.TextureResType.plistType) 
		end
		if data.maxhp then
			self.hp = data.maxhp
			self.MaxHp = data.maxhp
			self.headLayout:getWidgetByName("hp"):setPercent(self.hp,self.MaxHp):setFontSize(18)
		end
		if data.name then
			self.name = data.name
			self.headLayout:getWidgetByName("name"):setString(self.name)
			local nameLabel = self:getAvatar():getChildByName("nameLabel")
			if not nameLabel then
				nameLabel = ccui.Text:create()
				nameLabel:addTo(self:getAvatar())
					:align(display.CENTER, 0, 140)
					:setFontSize(20)
					:setLocalZOrder(100)
					:enableOutline(cc.c4b(24,19,11,200), 1)
					:setTextColor(cc.c4b(255,255,255,255))
					:setString(self.name)
			end
		end
		if data.guardLv then
			self.guardLv = data.guardLv
		end
		if data.dir then
			self.direction = data.dir
		end
		if data.clothId then
			self.clothId = data.clothId
			if self.clothId == 0 then
				self.clothId = self.gender==200 and 20000 or 10000
			end
			self:updateCloth(STATE.STAND)
		end
		if data.weaponId then
			self.weaponId = data.weaponId
			self:updateWeapon(STATE.STAND)
		end
		if data.wingId then
			self.wingId = data.wingId
			self:updateWing(STATE.STAND)
		end
	end
	local hpBar = self:getAvatar():getChildByName("hpBar")
	if not hpBar then
		hpBar = ccui.LoadingBar:create("image/icon/blood_normal.png",100):setName("hpBar")
		hpBar:addTo(self:getAvatar()):align(display.CENTER, 0, 120):setLocalZOrder(99)
		local hpBarbg = ccui.ImageView:create("image/icon/blood_normal_bg.png",ccui.TextureResType.localType):setName("hpBarbg")
		hpBarbg:addTo(self:getAvatar()):align(display.CENTER, 0, 120):setLocalZOrder(99)
	end
	self:getAvatar():show()
end
function player:subHp(hp)
	if GameUtilSenior.isObjectExist(self.headLayout) then
		self.hp = self.hp - hp
		self.hp = GameUtilSenior.bound(0, self.hp, self.MaxHp)
		self.headLayout:getWidgetByName("hp"):setPercentWithAnimation(self.hp, self.MaxHp)
		self:getAvatar():getChildByName("hpBar"):setPercent(100*self.hp/self.MaxHp)
	end
end
function player:isDie()
	return self.hp<=0
end

function player:updateCloth(action,nextAction)
	-- printKey( STATE,action )
	if not self.clothId or not action then return end
	local dir = self.direction
	action = action or STATE.STAND
	dir = dir or 4
	self:getAvatar().dir = dir;
	local isflip = false
	if dir>=5 then
		dir = 8-dir
		isflip = true
	end
	local img_role = self:getAvatar():getChildByName("cloth")
	if not img_role then
		img_role = cc.Sprite:create()--:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
		img_role:addTo(self:getAvatar()):setName("cloth"):align(display.CENTER, 0, 0):setLocalZOrder(0)
	end
	img_role:setFlippedX(isflip)
	img_role:setLocalZOrder(table.indexof(zorderTable[dir+1], "cloth"))
	local resId = 100 * self.clothId + action
	local animate = getActionAnimate(0,resId,action,dir,function(animate,shouldDownload)
		if animate then
			img_role:show():stopAllActions()
			img_role:stopAllActions()
			self.state = action
			if action == STATE.DIE then
				img_role:runAction(animate)
			else
				img_role:runAction(cca.seq({
					animate,
					cca.cb(function()
						if nextAction then
							self:updateCloth(nextAction)
						end
					end),
					cca.delay(1),
					cca.cb(function()
						self:updateCloth(STATE.STAND)
					end)
				}))
			end
		else
			img_role:hide()
		end
		if shouldDownload==true then
			img_role:release()
		end
	end,
	function()
		img_role:retain()
	end
	)--cc.AnimManager:getInstance():getPlistAnimate(0,resId,dir)
end
function player:updateWeapon(action,nextAction)
	if not self.weaponId or not action then return end
	local dir = self.direction
	action = action or STATE.STAND
	dir = dir or 4
	local isflip = false
	if dir>=5 then
		dir = 8-dir
		isflip = true
	end
	local img_weapon = self:getAvatar():getChildByName("weapon")
	if not img_weapon then
		img_weapon = cc.Sprite:create()--:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
		img_weapon:addTo(self:getAvatar()):setName("weapon"):align(display.CENTER, 0, 0):setLocalZOrder(0)
	end
	img_weapon:setFlippedX(isflip)
	img_weapon:setLocalZOrder(table.indexof(zorderTable[dir+1], "weapon"))
	local itemId = 100*self.weaponId + action
	local animate = getActionAnimate(1,itemId,action,dir,function(animate,shouldDownload)
		if animate then
			img_weapon:show():stopAllActions()
			if action == STATE.DIE then
				img_weapon:runAction(animate)
			else
				img_weapon:runAction(cca.seq({
					animate,
					cca.cb(function()
						if nextAction then
							self:updateWeapon(nextAction)
						end
					end),
					cca.delay(1),
					cca.cb(function()
						self:updateWeapon(STATE.STAND)
					end)
				}))
			end
		else
			img_weapon:hide()
		end
		if shouldDownload==true then
			img_weapon:release()
		end
	end,
	function()
		img_weapon:retain()
	end)--cc.AnimManager:getInstance():getPlistAnimate(1,itemId,dir)
end
function player:updateWing(action,nextAction)
	if not self.wingId or not action then return end
	local dir = self.direction
	action = action or STATE.STAND
	dir = dir or 4
	local isflip = false
	if dir>=5 then
		dir = 8-dir
		isflip = true
	end
	local img_wing = self:getAvatar():getChildByName("wing")
	if not img_wing then
		img_wing = cc.Sprite:create()--:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
		img_wing:addTo(self:getAvatar()):setName("wing"):align(display.CENTER, 0, 0):setLocalZOrder(0)
	end
	img_wing:setFlippedX(isflip)
	img_wing:setLocalZOrder(table.indexof(zorderTable[dir+1], "wing"))
	local wingId = self.wingId * 100 + action
	if self.wingId>0 then
		img_wing:show():stopAllActions()
		local animate = getActionAnimate(3,wingId,action,dir,function(animate,shouldDownload)
			if animate then
				if action == STATE.DIE then
					img_wing:runAction(animate)
				else
					img_wing:runAction(cca.seq({
						animate,
						cca.cb(function()
							if nextAction then
								self:updateWing(STATE.PREPARE)
							end
						end),
						cca.delay(1),
						cca.cb(function()
							self:updateWing(STATE.STAND)
						end)
					}))
				end
			else
				img_wing:hide()
			end
			if shouldDownload==true then
				img_wing:release()
			end
		end,
		function()
			img_wing:retain()
		end)--cc.AnimManager:getInstance():getPlistAnimate(3,wingId,dir)
		
	end
end
function player:useSkill(skillId,damage)
	local dir = self.direction
	local action = skill:getSkillAction(skillId,self:getAvatar(),self:getEnemy():getAvatar(),dir)
	if not action then action = cca.delay(1.4); end
	self:getAvatar():getParent():runAction(cca.seq({
		cca.cb(function(_)
			self:skill();
		end),
		action,
		cca.cb(function(_)
			self:getEnemy():subHp(damage);
			if self:getEnemy():isDie() then
				self:getEnemy():getAvatar():stopAllActions()
				self:getEnemy():die()
			end
		end),
		cca.delay(1),
		cca.cb(function(_)
			self:playActionSequence();
		end)
	}))
end
function player:run(logicPos)
	local pos = logicPosToPixesPos(logicPos.x,logicPos.y)
	pos = var.imgMap:convertToWorldSpace(pos)

	if pos and pos.x and pos.y then
		self:updateCloth(STATE.RUN,STATE.RUN)
		self:updateWeapon(STATE.RUN,STATE.RUN)
		self:updateWing(STATE.RUN,STATE.RUN)
		local time = moveTime({x=self:getAvatar():getPositionX(),y=self:getAvatar():getPositionY()},pos)
		self:getAvatar():runAction(cca.seq({
			cca.moveTo(time, pos.x, pos.y),
			cca.cb(function()
				self:playActionSequence()
			end)
		}))
	end
end
function player:attack(nextAction)
	self:updateCloth(STATE.ATTACK,nextAction)
	self:updateWeapon(STATE.ATTACK,nextAction)
	self:updateWing(STATE.ATTACK,nextAction)
end
function player:skill()
	if self.job == 100 then
		self:attack(STATE.PREPARE)
	else
		self:updateCloth(STATE.SKILL,STATE.PREPARE)
		self:updateWeapon(STATE.SKILL,STATE.PREPARE)
		self:updateWing(STATE.SKILL,STATE.PREPARE)
	end
end
function player:die()
	if self.state~=STATE.DIE then
		self:updateCloth(STATE.DIE)
		self:updateWeapon(STATE.DIE)
		self:updateWing(STATE.DIE)

		self:getAvatar():removeChildByName("mofadunSprite")
		self:getAvatar():getParent():removeChildByName(self.name.."dog")
	end
end
function player:beizhan()
	self:updateCloth(STATE.PREPARE)
	self:updateWeapon(STATE.PREPARE)
	self:updateWing(STATE.PREPARE)
end
function player:stand(logicPos)
	self:updateCloth(STATE.STAND)
	self:updateWeapon(STATE.STAND)
	self:updateWing(STATE.STAND)
	if logicPos then
		local pos = logicPosToPixesPos(logicPos.x,logicPos.y)
		self:getAvatar():runAction(cca.seq({
			cca.place(pos.x,pos.y),
			cca.delay(1.2),
			cca.cb(function()
				self:playActionSequence()
			end)
		}))
	end
end

function player:addEnemy(enemy)
	self.enemy = enemy;
end
function player:getEnemy(enemy)
	return self.enemy;
end
--召唤护卫
function player:callGuard(name,pos)
	if checkint(self.guardLv) >0 then
		self._guard = Guard:new({
			name = name,
			owner = self,
			enemy = self:getEnemy(),
			dir = self.direction,
			guardLv = self.guardLv,
		})
		if self._guard then
			self._guard:guardAction(STATE.STAND,pos)
		end
	end
end

function player:playActionSequence(sequ)
	if GameUtilSenior.isTable(sequ) then self.seq = sequ end
	local seq = self.seq[1]
	if not seq then return end
	table.remove(self.seq,1)
	if self:isDie() then self.seq = {} return end
	if seq.cmd == "new" then
		self:ctor({
			name = seq.name,
			level = seq.level,
			job = seq.job,
			gender = seq.gender,
			maxhp = seq.hp,
			clothId = seq.clothId,
			weaponId = seq.weaponId,
			wingId = seq.wingId,
			dir = seq.dir,
			guardLv = seq.huweiLv,
		})
		self:getAvatar():runAction(cca.seq({
			cca.delay(2),
			cca.cb(function()
				self:playActionSequence()				
			end)
		}))
	elseif seq.cmd == "em" then
		self:stand(seq.pos)
	elseif seq.cmd == "sd" then
		self:getAvatar():runAction(cca.seq({
			cca.cb(function()
				self:stand()
			end),
			cca.delay(seq.t),
			cca.cb(function()
				self:playActionSequence()				
			end)
		}))
	elseif seq.cmd =="cg" then
		self:callGuard(self.name)
		self:playActionSequence()
	elseif seq.cmd == "mt" then
		self:run(seq.pos)
	elseif seq.cmd == "usk" then
		self:useSkill(seq.sid,seq.dmg)
	elseif seq.cmd == "bz" then
		self:beizhan()
	elseif seq.cmd == "win" then
		if self:getAvatar().dog then
			self:getAvatar().dog:removeFromParent()
		end
		if self:getEnemy():getAvatar().dog then
			self:getEnemy():getAvatar().dog:removeFromParent()
		end
		self:stand()
		self.seq = {}
		self:getEnemy().seq = {}
		self:getEnemy():die()
		GDivSkill.showResult()
	end
end

function GDivSkill.init()
	var = {
		layer,
		MenPaiLayer,
		battleResult,
		imgMap,
	}
	var.layer = ccui.Layout:create()
	var.layer:hide():align(display.CENTER, 0, 0)
	var.layer:setTouchEnabled(true)
	var.layer:setTouchSwallowEnabled(true)
	var.layer:setBackGroundImage("bg_4", ccui.TextureResType.plistType)

	local imgMap = ccui.ImageView:create()
	imgMap:setScale9Enabled(true)
		:size(display.width, display.height)
		:align(display.LEFT_BOTTOM, 0, 0)
		:addTo(var.layer)
		:setName("imgMap")
		:setCascadeOpacityEnabled(true)
		:setContentSize(mapSize)
		-- :loadTexture("btn_tips_button", ccui.TextureResType.plistType)
	var.imgMap = imgMap;
	cc.EventProxy.new(GameSocket,var.layer)
		:addEventListener(GameMessageCode.EVENT_MENPAI_BATTLE, GDivSkill.msgHandler)
		:addEventListener(GameMessageCode.EVENT_CHANGE_MAP, function()
			if GameSocket.mNetMap.mMapID~="menpai" and var.layer:isVisible() then
				GDivSkill.exitBattle()
			end
		end)

	return var.layer
end

function GDivSkill.msgHandler(event)
	if event.visible then
		GDivSkill.showBattle(event)
	else
		GDivSkill.exitBattle()
	end
end

function GDivSkill.showBattle(event)
	if not var.layer then return end
	var.layer:show()
	if not GameUtilSenior.isObjectExist(var.MenPaiLayer) then
		asyncload_frames("ui/sprite/MenPaiLayer",".png",function ()
			GDivSkill.initLayerView(event)
		end,var.layer)
	else
		GDivSkill.initLayerView(event)
	end

	GUIMain.m_lcPartUI:hide()
end

function GDivSkill.initLayerView(event)
	GUIMain.m_ltPartUI:setVisible(false)
	GUIMain.m_rtPartUI:setVisible(false)
	if not var.MenPaiLayer then
		var.MenPaiLayer = GUIAnalysis.load("ui/layout/MenPaiLayer.uif")
		if var.MenPaiLayer then
			var.MenPaiLayer:addTo(var.layer)
				:setContentSize(cc.size(display.width, display.height))
				:align(display.CENTER, display.cx, display.cy)
				:show()
			GDivSkill.renderMap()
		end
	end
	local btnExit = var.MenPaiLayer:getWidgetByName("btnExit")
	if not btnExit then
		btnExit = ccui.Button:create("btn_menpai_exit","btn_menpai_exit","",ccui.TextureResType.plistType)
		btnExit:addTo(var.MenPaiLayer):setName("btnExit"):align(display.RIGHT_BOTTOM, display.width-300, 160)
		btnExit:setPressedActionEnabled(true):setLocalZOrder(9)
		btnExit:setZoomScale(-0.12)
		btnExit:addClickEventListener(function()
			GDivSkill.exitBattle("noSend")
		end)
	end
	btnExit:show()
	local headLayout1 = var.MenPaiLayer:getWidgetByName("headLayout1")
	local headLayout2 = var.MenPaiLayer:getWidgetByName("headLayout2")
	headLayout1:align(display.LEFT_TOP, 0, display.height)
	headLayout2:align(display.RIGHT_TOP, display.width, display.height)
	var.MenPaiLayer:getWidgetByName("PanelResult"):hide()
	local battlecountdown = var.MenPaiLayer:getWidgetByName("battlecountdown")
	battlecountdown:align(display.CENTER, display.cx, display.height-20):show()
	local countDownNum = battlecountdown:getChildByName("countDownNum")
	if not countDownNum then
		countDownNum = display.newBMFontLabel({font = "image/typeface/num_14.fnt"})
		countDownNum:addTo(battlecountdown)
		:setName("countDownNum")
		:align(display.CENTER,battlecountdown:getContentSize().width/2,-30)
		:show():setString("0")
	end
	if event then
		GDivSkill.battlePerformance(event)
	end
	local count = 3
	GameUtilSenior.runCountDown(countDownNum,count,function( target ,second)
		target:setString(second)
		if second==0 then
			battlecountdown:hide()
		end
	end)
end

function GDivSkill.showResult(data)
	if not GameUtilSenior.isObjectExist(var.MenPaiLayer) then return end
	if not data then
		data = var.battleResult
	end
	local PanelResult = var.MenPaiLayer:getWidgetByName("PanelResult")
	PanelResult:setAnchorPoint(cc.p(0.5,1)):setPosition(display.width/2,display.height):show()
	local mychart = PanelResult:getWidgetByName("mychart")
	local Image_award = PanelResult:getWidgetByName("Image_award")
	local cellbg1 = PanelResult:getWidgetByName("cellbg1")
	local cellbg2 = PanelResult:getWidgetByName("cellbg2")
	local cellbg3 = PanelResult:getWidgetByName("cellbg3")
	local img_result = PanelResult:getWidgetByName("img_result")
	local btn_operate = PanelResult:getWidgetByName("btn_operate")
	local lblcountdown = PanelResult:getWidgetByName("lblcountdown")
	local lblchart = mychart:getWidgetByName("lblchart")
	if not lblchart then
		lblchart = GUIRichLabel.new({name = "lblchart",ignoreSize = true,anchor = cc.p(0.5,0)})
		lblchart:addTo(mychart)
	end
	local btnExit = var.MenPaiLayer:getWidgetByName("btnExit")
	if btnExit then
		btnExit:hide()
	end
	local success = data.success
	local str,chart,btnTitle = "",data.rank,"退出"--,data.chart
	if success == "success" then
		if data.posChange then
			str = "<font color=#30ff00 size=22>我的排名上升到"..chart.."</font>"
		else
			str = "<font color=#30ff00 size=22>我的排名"..chart.."(排名不变)</font>"
		end
		btnTitle = "领取翻牌"
		img_result:loadTexture("img_menpai_vectory", ccui.TextureResType.plistType)
		Image_award:pos(320,345)
		cellbg1:pos(300,345):hide()
		cellbg2:pos(400,345):show()
		cellbg3:pos(500,345):hide()
		-- btn_operate:pos(400,215)
	else
		Image_award:pos(320,365)
		cellbg1:pos(300,300):hide()
		cellbg2:pos(400,300):show()
		cellbg3:pos(500,300):hide()
		-- btn_operate:pos(400,215)
		img_result:loadTexture("img_menpai_lose", ccui.TextureResType.plistType)
		btnTitle = "退出"
		str = "<font color=#99958e>很遗憾挑战失败，您的排名依旧是</font><font color=#ffae00 size=24>"..chart.."</font>"
	end
	GUIItem.getItem({
		parent = cellbg2,
		typeId = data.scoreTable.id,
		num = data.scoreTable.num
	})
	btn_operate:setTitleText(btnTitle)
	lblchart:setRichLabel(str, "lblchart", 22)
	local carddata = data.turncardTable or {
		{id = 23060001,name="name",num = 1},
		{id = 23060001,name="name",num = 2},
		{id = 23060001,name="name",num = 3},
		{id = 23060001,name="name",num = 4},
		{id = 23060001,name="name",num = 5},
	}
	local count = data.count or 5
	local cardModel = var.MenPaiLayer:getWidgetByName("card")
	local selectIndex = nil
	local defaultIndex = data.selected or 1
	local isGotCard = false --开启翻牌
	local function initCard(cardwidget,isface,cdata)
		local cellbg = cardwidget:getWidgetByName("cellbg")
		local name = cardwidget:getWidgetByName("name")
		local num = cardwidget:getWidgetByName("num")
		if cdata then
			GUIItem.getItem({parent = cellbg,typeId = cdata.id})
			name:show():setString(cdata.name or "")
			num:show():setString(cdata.num or "")
		end
		if isface then
			name:show()
			num:show()
			cellbg:show()
			cardwidget:loadTexture("img_menpai_forgroud", ccui.TextureResType.plistType)
		else
			cardwidget:loadTexture("img_card_background", ccui.TextureResType.plistType)
			cellbg:hide()
			name:hide()
			num:hide()
		end
	end
	local function autoExit()
		--自动退出
		count = 5
		GameUtilSenior.runCountDown(lblcountdown,count,function( target,countdown )
			target:setString(countdown.."秒后自动退出")
			if countdown==0 then
				GDivSkill.exitBattle()
			end
		end)
	end
	local function turnCardToFace(cardwidget)
		selectIndex = cardwidget.index
		local cellbg = cardwidget:getWidgetByName("cellbg")
		local name = cardwidget:getWidgetByName("name")
		local num = cardwidget:getWidgetByName("num")
		cardwidget:runAction(cca.seq({
			-- cca.spawn({
			-- 	cc.SkewTo:create(0.4,0,5),
				cca.scaleTo(0.4,0.01,1),
			-- }),
			cca.cb(function(target)
				initCard(target,true)
			end),
			-- cca.spawn({
			-- 	cc.SkewTo:create(0.4,0,0),
				cca.scaleTo(0.4,1,1),
			-- }),
			cca.cb(function (target)
				btn_operate:setEnabled(true)
				local cid = data.turncardTable[defaultIndex] or 1
				GameSocket:PushLuaTable("npc.menpai.onPanelData",GameUtilSenior.encode({actionid = "getBattleAward",cid = cid}))
			end),
		}))
	end
	local function showCard()
		for i=1,5 do
			local cardi = PanelResult:getChildByName("card"..i)
			if not cardi then
				cardi = cardModel:clone():show()
				cardi:addTo(PanelResult):setName("card"..i)
			end
			cardi:pos(400,200):setTouchEnabled(true)
			initCard(cardi,false,carddata[i])
			cardi:runAction(cca.seq({
				cca.moveTo(0.2, 400+(i-3)*140, 200),
				cca.cb(function(target)

				end)
			}))
			cardi.index = i
			cardi:addClickEventListener(function ( sender )
				if not selectIndex then
					selectIndex = sender.index
					if selectIndex ~= defaultIndex then
						--交换两张卡信息
						initCard(PanelResult:getChildByName("card"..selectIndex),false,carddata[defaultIndex])
						initCard(PanelResult:getChildByName("card"..defaultIndex),false,carddata[selectIndex])
					end
					turnCardToFace(sender)
					autoExit()
				end
			end)
		end
	end
	local function runShowCardCountDown()
		if isGotCard then return end
		count = 10
		isGotCard = true
		showCard()
		GameUtilSenior.runCountDown(lblcountdown,count,function( target,countdown )
			target:setString(countdown.."秒后自动翻牌")
			if countdown==0 and not selectIndex then
				selectIndex = defaultIndex
				local cardselect = PanelResult:getWidgetByName("card"..selectIndex)
				if cardselect then
					target:stopAllActions()
					turnCardToFace(cardselect)
					autoExit()
				end
			end
		end)
		btn_operate:setPositionY(80):setTitleText("退出"):setEnabled(false)
	end
	btn_operate:setPositionY(215)
	btn_operate:addClickEventListener(function( sender )
		if sender:getTitleText() =="退出" then
			GDivSkill.exitBattle()
		else
			lblcountdown:stopAllActions()
			runShowCardCountDown()
		end
	end)
	GameUtilSenior.runCountDown(lblcountdown,count,function( target,countdown )
		if success == "success" then
			target:setString(countdown.."秒后开启翻牌")
			if countdown==0 then
				runShowCardCountDown()
			end
		else
			target:setString(countdown.."秒后自动退出")
			if countdown == 0 then
				target:stopAllActions()
				GDivSkill.exitBattle()
			end
		end
	end)
end

function GDivSkill.battlePerformance(info)
	local battleLayer = var.layer:getChildByName("battleLayer")
	if not battleLayer then
		battleLayer = ccui.Layout:create()
		battleLayer:addTo(var.imgMap):setName("battleLayer"):setLocalZOrder(3)
		battleLayer:setContentSize(mapSize):align(display.LEFT_BOTTOM,-(mapSize.width-GameConst.WIN_WIDTH)/2,-(mapSize.height-GameConst.WIN_HEIGHT)/2)
	end
	battleLayer:removeAllChildren()

	local player1 = player:new();
	local player2 = player:new();
	local pos1 = logicPosToPixesPos(15,18);
	player1:getAvatar():addTo(battleLayer):setName("player1"):align(display.CENTER,pos1.x,pos1.y)
	local pos2 = logicPosToPixesPos(25,18);
	player2:getAvatar():addTo(battleLayer):setName("player2"):align(display.CENTER,pos2.x,pos2.y)
	player1:bindHeadLayout(var.MenPaiLayer:getWidgetByName("headLayout1"))
	player2:bindHeadLayout(var.MenPaiLayer:getWidgetByName("headLayout2"))

	player1:addEnemy(player2)
	player2:addEnemy(player1)

	var.battleResult = {
		success = info.result,
		scoreTable = info.scoreTable,
		turncardTable = info.turncardTable,
		selected = info.selected,
		posChange = info.posChange,
		rank = info.rank,
	}
	player1:playActionSequence(info.mine.seq)
	player2:playActionSequence(info.other.seq)
end

function GDivSkill.renderMap()
	local imgMap = var.layer:getChildByName("imgMap")
	imgMap:removeAllChildren()
	local md = {r_min = 1,r_max = 9,c_min = 1,c_max = 11,mapId = "v406",offset = mapOffset}
	local mapGrid
	local pSize = cc.size(256,256)
	for r = md.r_min,md.r_max do
		for c = md.c_min, md.c_max do
			local res = string.format("map/complete/%s/%s_r%s_c%s.jpg",md.mapId,md.mapId,r,c)
			mapGrid = imgMap:getChildByName(string.format("%s%s", r, c))
			if not mapGrid then
				mapGrid = ccui.ImageView:create(res, ccui.TextureResType.localType):addTo(imgMap)
				mapGrid:setName(string.format("%s%s", r, c))
			else
				--mapGrid:loadTexture(res, ccui.TextureResType.localType)
						
				asyncload_callback(res, mapGrid, function(path, texture)
					mapGrid:loadTexture(path)
				end)
			end
			mapGrid:align(display.LEFT_TOP, (c-md.c_min) * pSize.width + md.offset.x, display.height - (r-md.r_min) * pSize.height + md.offset.y)
			mapGrid:setTouchEnabled(true):setTouchSwallowEnabled(true):setLocalZOrder(0)
		end
	end
end

function GDivSkill.exitBattle(noSend)
	if GameUtilSenior.isObjectExist(var.MenPaiLayer) then
		var.MenPaiLayer:removeFromParent()
	end
	if GameUtilSenior.isObjectExist(var.layer) then
		local battleLayer = var.layer:getWidgetByName("battleLayer")
		if battleLayer then
			battleLayer:removeFromParent()
		end
		var.layer:hide()
	end
	GUIMain.m_ltPartUI:setVisible(true)
	GUIMain.m_rtPartUI:setVisible(true)
	var.MenPaiLayer = nil
	var.battleResult = {}
	remove_frames("ui/sprite/MenPaiLayer",".png")
	cc.CacheManager:getInstance():releaseUnused(false)
	cc.AnimManager:getInstance():remAllAnimate()
	GUIMain.m_lcPartUI:show()
	if not noSend then
		GameSocket:PushLuaTable("npc.menpai.onPanelData",GameUtilSenior.encode({actionid = "freshlefttips"}))
	end
end

GDivSkill.newSkillAnimateWithFrameData = newSkillAnimateWithFrameData;
GDivSkill.getActionAnimate = getActionAnimate;
GDivSkill.moveTime = moveTime
GDivSkill.logicPosToPixesPos = logicPosToPixesPos
GDivSkill.pixesPosToLogicPos = pixesPosToLogicPos
GDivSkill.STATE = STATE
GDivSkill.zorderTable = zorderTable;

return GDivSkill