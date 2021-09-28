------------------------------------------------------
local require = require

require("i3k_global");
require("i3k_db");


------------------------------------------------------------------
local TStyle1 = nil;
local TStyle2 = nil;
local TStyle3 = nil;
local TStyle4 = nil;
local TStyle5 = nil;
local TStyle6 = nil;
local TStyle7 = nil;--add by wangzhaoyang
local TStyle8 = nil;--add by wangzhaoyang
local TStyle9 = nil;--add by wangzhaoyang

local AnimData1 	= nil;
local AnimData2 	= nil;
local AnimData3 	= nil;
local AnimData4 	= nil;
local AnimData5 	= nil;
local AnimData6 	= nil;
local AnimData7 	= nil;
local AnimData8 	= nil;
local AnimData9 	= nil;
local AnimData10	= nil;
local AnimData11	= nil;
local AnimData12	= nil; --add by wangzhaoyang
local AnimData13	= nil; --add by wangzhaoyang
local AnimData14	= nil; --add by wangzhaoyang
local AnimData15	= nil; --add by wangzhaoyang
local AnimData16	= nil; --add by wangzhaoyang

local TextAnimData1 = nil;
local TextAnimData2 = nil;
local TextAnimData3 = nil;
local TextAnimData4 = nil;
local TextAnimData5 = nil;
local TextAnimData6 = nil;
local TextAnimData7 = nil;
local TextAnimData8 = nil;
local TextAnimData9 = nil; --add by wangzhaoyang
local TextAnimData10 = nil; --add by wangzhaoyang
local TextAnimData11 = nil; --add by wangzhaoyang

-- 动画差值
local eIT_PolyLine    = 0; --折线
local eIT_Lerp        = 1; --线性
local eIT_CatmullRom  = 2; --hermite使用顶点连线做切线的简化版


------------------------------------------------------------------
i3k_text_effect = i3k_class("i3k_text_effect");
function i3k_text_effect:ctor(name)
	self._name
		= name;
	self._effect
		= Engine.TextEffect();
	self._effectIDs
		= { };
	self._curEffType
		= 0;
	self._canUse
		= true;
	self._timeDel
		= 0;
	self._duration
		= 0;
	self._createRes
		= false;
end

function i3k_text_effect:CreateRes()
	if not self._createRes then
		self._createRes = true;
		--角色的治疗-AnimData:缩放-TStyle:字体颜色-TextAnimData:字色变化动画
		local v1 = Engine.AnimVector();
		v1:push_back(AnimData1:Self());
		v1:push_back(AnimData4:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v1', TStyle1, v1), anim_t = TextAnimData1 });
		--怪物的治疗
		local v2 = Engine.AnimVector();
		v2:push_back(AnimData9:Self());
		v2:push_back(AnimData4:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v2', TStyle1, v2), anim_t = TextAnimData1 });
		--角色的伤害
		local v3 = Engine.AnimVector();
		v3:push_back(AnimData1:Self());
		v3:push_back(AnimData4:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v3', TStyle2, v3), anim_t = TextAnimData2 });
		--怪物的伤害
		local v4 = Engine.AnimVector();
		v4:push_back(AnimData9:Self());
		v4:push_back(AnimData4:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v4', TStyle3, v4), anim_t = TextAnimData3 });
		--佣兵的伤害
		local v5 = Engine.AnimVector();
		v5:push_back(AnimData1:Self());
		v5:push_back(AnimData4:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v5', TStyle7, v5), anim_t = TextAnimData9 });
		--角色的暴击伤害
		local v6 = Engine.AnimVector();
		v6:push_back(AnimData2:Self());
		v6:push_back(AnimData5:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v6', TStyle3, v6), anim_t = TextAnimData3 });
		--怪物的暴击伤害
		local v7 = Engine.AnimVector();
		v7:push_back(AnimData10:Self());
		v7:push_back(AnimData5:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v7', TStyle3, v7), anim_t = TextAnimData3 });
		--佣兵的暴击伤害
		local v8 = Engine.AnimVector();
		v8:push_back(AnimData2:Self());
		v8:push_back(AnimData5:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v8', TStyle7, v8), anim_t = TextAnimData9 });
		--角色的SP
		local v9 = Engine.AnimVector();
		v9:push_back(AnimData2:Self());
		v9:push_back(AnimData5:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v9', TStyle4, v9), anim_t = TextAnimData4 });
		--怪物/佣兵的SP
		local v10 = Engine.AnimVector();
		v10:push_back(AnimData10:Self());
		v10:push_back(AnimData5:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v10', TStyle4, v10), anim_t = TextAnimData4 });
		--角色的闪避
		local v11 = Engine.AnimVector();
		v11:push_back(AnimData1:Self());
		v11:push_back(AnimData4:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v11', TStyle5, v11), anim_t = TextAnimData5 });
		--怪物的闪避
		local v12 = Engine.AnimVector();
		v12:push_back(AnimData9:Self());
		v12:push_back(AnimData4:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v12', TStyle5, v12), anim_t = TextAnimData5 });
		--佣兵的闪避
		local v13 = Engine.AnimVector();
		v13:push_back(AnimData1:Self());
		v13:push_back(AnimData4:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v13', TStyle5, v13), anim_t = TextAnimData5 });
		--角色的BUFF
		local v14 = Engine.AnimVector();
		v14:push_back(AnimData7:Self());
		v14:push_back(AnimData8:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v14', TStyle6, v14), anim_t = TextAnimData7 });
		--怪物的BUFF
		local v15 = Engine.AnimVector();
		v15:push_back(AnimData11:Self());
		v15:push_back(AnimData8:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v15', TStyle6, v15), anim_t = TextAnimData8 });
		--佣兵的BUFF
		local v16 = Engine.AnimVector();
		v16:push_back(AnimData11:Self());
		v16:push_back(AnimData8:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v16', TStyle5, v16), anim_t = TextAnimData7 });
		--角色的暴击治疗
		local v17 = Engine.AnimVector();
		v17:push_back(AnimData2:Self());
		v17:push_back(AnimData5:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v17', TStyle1, v17), anim_t = TextAnimData1 });
		--怪物的暴击治疗
		local v18 = Engine.AnimVector();
		v18:push_back(AnimData10:Self());
		v18:push_back(AnimData5:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v18', TStyle1, v18), anim_t = TextAnimData3 });
		--佣兵的暴击治疗
		local v19 = Engine.AnimVector();
		v19:push_back(AnimData2:Self());
		v19:push_back(AnimData5:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v19', TStyle1, v19), anim_t = TextAnimData9 });
		--陷阱的伤害
		local v20 = Engine.AnimVector();
		v20:push_back(AnimData9:Self());
		v20:push_back(AnimData4:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v20', TStyle3, v20), anim_t = TextAnimData3 });
		--自创武功的冒字
		local v21 = Engine.AnimVector();
		v21:push_back(AnimData15:Self());
		v21:push_back(AnimData16:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v21', TStyle8, v21), anim_t = TextAnimData10 });
		--绝技的冒字
		local v22 = Engine.AnimVector();
		v22:push_back(AnimData13:Self());
		v22:push_back(AnimData14:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v22', TStyle9, v22), anim_t = TextAnimData11 });
		--内伤的冒字
		local v23 = Engine.AnimVector();
		v23:push_back(AnimData17:Self());
		v23:push_back(AnimData18:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v23', TStyle2, v23), anim_t = TextAnimData2 });
		--引发内伤的冒字
		local v24 = Engine.AnimVector();
		v24:push_back(AnimData17:Self());
		v24:push_back(AnimData19:Self());
		table.insert(self._effectIDs, { id = self._effect:AddStyle(self._name, 'v24', TStyle2, v24), anim_t = TextAnimData2 });
	end
end

function i3k_text_effect:SetText(effType, pos, text, duration)
	if self._canUse then
		if not self._createRes then
			self:CreateRes();
		end

		if self._effectIDs then
			local id = self._effectIDs[effType].id;
			if id then
				if self._effect:UpdateText(id, pos, text, duration) then
					self._effect:UseStyle(id, true);
					self._curEffType	= effType;
					self._canUse		= false;
					self._timeDel		= 0;
					self._duration		= duration;

					return true;
				end
			end
		end
	end

	return false;
end

function i3k_text_effect:OnUpdate(dTime)
	if not self._canUse then
		self._timeDel = self._timeDel + dTime;
		if self._timeDel > self._duration then
			self._canUse = true;

			self._effect:Stop();

			local id = self._effectIDs[self._curEffType].id;
			if id then
				self._effect:UseStyle(id, false);
			end
		else
			local _d = self._effectIDs[self._curEffType].anim_t:GetAnimData(self._timeDel);
			if _d then
				self._effect:UpdateColor(_d.mColor, _d.mTopColor, _d.mBottomColor);
			end
		end
	end
end

function i3k_text_effect:Stop()
	if not self._canUse then
		self._canUse	= true;
		self._timeDel 	= 0;
		self._duration	= 0;

		self._effect:Stop();

		local id = self._effectIDs[self._curEffType].id;
		if id then
			self._effect:UseStyle(id, false);
		end
	end
end

------------------------------------------------------------------
i3k_image_effect = i3k_class("i3k_image_effect");
function i3k_image_effect:ctor(name, image)
	self._created	= false;
	self._canUse	= true;
	self._valid		= false;
	self._name		= name;
	self._image		= image;
end

function i3k_image_effect:IsCreatRes()
	return self._created;
end

function i3k_image_effect:CreateRes()
	self._effect	= Engine.ImageEffect();
	self._valid		= self._effect:Create(self._name, self._image, "", "") ~= -1;
	self._timeDel	= 0;
	self._duration	= 0;
	self._curAni	= 0;
	self._created	= true;

	self._animation	= { };
	if self._valid then
		--角色的治疗
		local v1 = Engine.AnimVector();
		v1:push_back(AnimData1:Self());
		v1:push_back(AnimData4:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v1), anim_t = TextAnimData1 });

		--怪物的治疗
		local v2 = Engine.AnimVector();
		v2:push_back(AnimData9:Self());
		v2:push_back(AnimData4:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v2), anim_t = TextAnimData1 });

		--角色的伤害
		local v3 = Engine.AnimVector();
		v3:push_back(AnimData1:Self());
		v3:push_back(AnimData4:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v3), anim_t = TextAnimData2 });

		--怪物的伤害
		local v4 = Engine.AnimVector();
		v4:push_back(AnimData9:Self());
		v4:push_back(AnimData4:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v4), anim_t = TextAnimData3 });

		--佣兵的伤害
		local v5 = Engine.AnimVector();
		v5:push_back(AnimData1:Self());
		v5:push_back(AnimData4:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v5), anim_t = TextAnimData9 });

		--角色的暴击伤害
		local v6 = Engine.AnimVector();
		v6:push_back(AnimData2:Self());
		v6:push_back(AnimData5:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v6), anim_t = TextAnimData3 });

		--怪物的暴击伤害
		local v7 = Engine.AnimVector();
		v7:push_back(AnimData10:Self());
		v7:push_back(AnimData5:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v7), anim_t = TextAnimData3 });

		--佣兵的暴击伤害
		local v8 = Engine.AnimVector();
		v8:push_back(AnimData2:Self());
		v8:push_back(AnimData5:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v8), anim_t = TextAnimData9 });

		--角色的SP
		local v9 = Engine.AnimVector();
		v9:push_back(AnimData2:Self());
		v9:push_back(AnimData5:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v9), anim_t = TextAnimData4 });

		--怪物/佣兵的SP
		local v10 = Engine.AnimVector();
		v10:push_back(AnimData10:Self());
		v10:push_back(AnimData5:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v10), anim_t = TextAnimData4 });

		--角色的闪避
		local v11 = Engine.AnimVector();
		v11:push_back(AnimData1:Self());
		v11:push_back(AnimData4:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v11), anim_t = TextAnimData5 });

		--怪物的闪避
		local v12 = Engine.AnimVector();
		v12:push_back(AnimData9:Self());
		v12:push_back(AnimData4:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v12), anim_t = TextAnimData5 });

		--佣兵的闪避
		local v13 = Engine.AnimVector();
		v13:push_back(AnimData1:Self());
		v13:push_back(AnimData4:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v13), anim_t = TextAnimData5 });

		--角色的BUFF
		local v14 = Engine.AnimVector();
		v14:push_back(AnimData7:Self());
		v14:push_back(AnimData8:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v14), anim_t = TextAnimData7 });

		--怪物的BUFF
		local v15 = Engine.AnimVector();
		v15:push_back(AnimData11:Self());
		v15:push_back(AnimData8:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v15), anim_t = TextAnimData8 });

		--佣兵的BUFF
		local v16 = Engine.AnimVector();
		v16:push_back(AnimData11:Self());
		v16:push_back(AnimData8:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v16), anim_t = TextAnimData7 });

		--角色的暴击治疗
		local v17 = Engine.AnimVector();
		v17:push_back(AnimData2:Self());
		v17:push_back(AnimData5:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v17), anim_t = TextAnimData1 });

		--怪物的暴击治疗
		local v18 = Engine.AnimVector();
		v18:push_back(AnimData10:Self());
		v18:push_back(AnimData5:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v18), anim_t = TextAnimData3 });

		--佣兵的暴击治疗
		local v19 = Engine.AnimVector();
		v19:push_back(AnimData2:Self());
		v19:push_back(AnimData5:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v19), anim_t = TextAnimData9 });

		--陷阱的伤害
		local v20 = Engine.AnimVector();
		v20:push_back(AnimData9:Self());
		v20:push_back(AnimData4:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v20), anim_t = TextAnimData3 });

		--自创武功的冒字
		local v21 = Engine.AnimVector();
		v21:push_back(AnimData15:Self());
		v21:push_back(AnimData16:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v21), anim_t = TextAnimData10 });

		--绝技的冒字
		local v22 = Engine.AnimVector();
		v22:push_back(AnimData13:Self());
		v22:push_back(AnimData14:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v22), anim_t = TextAnimData11 });
		--内伤的冒字
		local v23 = Engine.AnimVector();
		v23:push_back(AnimData17:Self());
		v23:push_back(AnimData18:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v23), anim_t = TextAnimData2 });
		--引发内伤的冒字
		local v24 = Engine.AnimVector();
		v24:push_back(AnimData17:Self());
		v24:push_back(AnimData19:Self());
		table.insert(self._animation, { id = self._effect:AddAnimation(v24), anim_t = TextAnimData2 });
	end
end

function i3k_image_effect:ReleaseRes()
	if self._effect then
		self._effect:Release();
		self._effect = nil;
	end
end

function i3k_image_effect:UseAni(ani)
	if self._animation[ani] ~= nil then
		self._curAni = ani;

		self._effect:UseAnimation(self._animation[ani].id);
	end
end

function i3k_image_effect:SetText(pos, prefix, text, duration)
	if self._valid and self._canUse then
		if self._effect:UpdateText(pos, prefix, Engine.UTF82A(text)) then
			self._effect:Active(true);

			self._canUse 	= false;
			self._timeDel 	= 0;
			self._duration	= duration;

			return true;
		end
	end

	return false;
end

function i3k_image_effect:CanUse()
	return self._canUse;
end

function i3k_image_effect:InUse()
	return not self._canUse;
end

function i3k_image_effect:OnUpdate(dTime)
	if self._valid and not self._canUse then
		self._timeDel = self._timeDel + dTime;
		if self._timeDel > self._duration then
			self._canUse = true;

			self._effect:Stop();
			self._effect:Active(false);
		else
			local _d = self._animation[self._curAni].anim_t:GetAnimData(self._timeDel);
			if _d then
				self._effect:UpdateTextColor(_d.mTopColor, _d.mBottomColor);
			end
		end
	end
end

function i3k_image_effect:Stop()
	if self._valid and not self._canUse then
		self._canUse	= true;
		self._timeDel 	= 0;
		self._duration	= 0;

		self._effect:Stop();
		self._effect:Active(false);
	end
end

------------------------------------------------------------------
i3k_camera_shake_effect = i3k_class("i3k_camera_shake_effect");
function i3k_camera_shake_effect:ctor(name, durtime)
	self._effect
		= Engine.CameraShakeEffect();
	self._effect:Create(durtime, name);

	self._effect:AddKeyFrame(durtime *  1 / 15, Engine.SVector3(-0.15,  0.15,  0.15));
	self._effect:AddKeyFrame(durtime *  2 / 15, Engine.SVector3( 0.15, -0.15, -0.15));
	self._effect:AddKeyFrame(durtime *  3 / 15, Engine.SVector3( 0.15,  0.15, -0.15));
	self._effect:AddKeyFrame(durtime *  4 / 15, Engine.SVector3(-0.15, -0.15,  0.15));
	self._effect:AddKeyFrame(durtime *  5 / 15, Engine.SVector3( 0.00,  0.15, -0.15));
	self._effect:AddKeyFrame(durtime *  6 / 15, Engine.SVector3( 0.00, -0.15,  0.30));
	self._effect:AddKeyFrame(durtime *  7 / 15, Engine.SVector3(-0.15, -0.15, -0.15));
	self._effect:AddKeyFrame(durtime *  8 / 15, Engine.SVector3( 0.15,  0.15,  0.15));
	self._effect:AddKeyFrame(durtime *  9 / 15, Engine.SVector3( 0.00, -0.15, -0.30));
	self._effect:AddKeyFrame(durtime * 10 / 15, Engine.SVector3( 0.00,  0.15,  0.15));
	self._effect:AddKeyFrame(durtime * 11 / 15, Engine.SVector3( 0.15, -0.15,  0.10));
	self._effect:AddKeyFrame(durtime * 12 / 15, Engine.SVector3(-0.30,  0.15, -0.10));
	self._effect:AddKeyFrame(durtime * 13 / 15, Engine.SVector3( 0.15,  0.15, -0.10));
	self._effect:AddKeyFrame(durtime * 14 / 15, Engine.SVector3( 0.15, -0.15,  0.10));
	self._effect:AddKeyFrame(durtime * 15 / 15, Engine.SVector3(-0.15,  0.00,  0.00));
end

function i3k_camera_shake_effect:Play()
	local flag = g_i3k_game_context:GetCameraShake()
	if self._effect and flag then
		self._effect:Play();
	end
end

function i3k_camera_shake_effect:Pause()
	if self._effect then
		self._effect:Pause();
	end
end

function i3k_camera_shake_effect:Stop()
	if self._effect then
		self._effect:Stop();
	end
end

function i3k_camera_shake_effect:OnUpdate(dTime)
	if self._effect then
		self._effect:Update(dTime);
	end
end

g_i3k_camera_shake_effect = nil;


------------------------------------------------------------------
i3k_effect_mgr = i3k_class("i3k_effect_mgr");
function i3k_effect_mgr:ctor(poolsize)
	self._poolsize	= poolsize;

	--
	TStyle1 = Engine.TextStyle(); -- heal
	TStyle1.mHeight 		= 0.5;
	TStyle1.mRatio			= 2.5;
	TStyle1.mFontName 		= i3k_db_common.engine.defaultFont;
	TStyle1.mTextColor		= tonumber("00ffffff", 16);
	TStyle1.mTopColor		= tonumber("ff24ef8b", 16);
	TStyle1.mBottomColor	= tonumber("ff00c65c", 16);

	TStyle2 = Engine.TextStyle(); -- damage
	TStyle2.mHeight 		= 0.5;
	TStyle2.mRatio			= 2.5;
	TStyle2.mFontName 		= i3k_db_common.engine.defaultFont;
	TStyle2.mTextColor		= tonumber("00ffffff", 16);
	TStyle2.mTopColor		= tonumber("ff011df2", 16);
	TStyle2.mBottomColor	= tonumber("ff6fc5f0", 16);

	TStyle3 = Engine.TextStyle(); -- damage enemy
	TStyle3.mHeight 		= 0.5;
	TStyle3.mRatio			= 2.5;
	TStyle3.mFontName 		= i3k_db_common.engine.defaultFont;
	TStyle3.mTextColor		= tonumber("00ffffff", 16);
	TStyle3.mTopColor		= tonumber("ff6fc5f0", 16);
	TStyle3.mBottomColor	= tonumber("ff011df2", 16);

	TStyle4 = Engine.TextStyle(); -- sp
	TStyle4.mHeight 		= 0.5;
	TStyle4.mRatio			= 2.5;
	TStyle4.mFontName 		= i3k_db_common.engine.defaultFont;
	TStyle4.mTextColor		= tonumber("00ffffff", 16);
	TStyle4.mTopColor		= tonumber("ff8deffd", 16);
	TStyle4.mBottomColor	= tonumber("ff3eb5f6", 16);

	TStyle5 = Engine.TextStyle(); -- buff
	TStyle5.mHeight 		= 0.5;
	TStyle5.mRatio			= 2.5;
	TStyle5.mFontName 		= i3k_db_common.engine.defaultFont;
	TStyle5.mTextColor		= tonumber("00ffffff", 16);
	TStyle5.mTopColor		= tonumber("ffeb993a", 16);
	TStyle5.mBottomColor	= tonumber("ffeb993a", 16);

	TStyle6 = Engine.TextStyle(); -- buff enemy
	TStyle6.mHeight 		= 0.5;
	TStyle6.mRatio			= 2.5;
	TStyle6.mFontName 		= i3k_db_common.engine.defaultFont;
	TStyle6.mTextColor		= tonumber("00ffffff", 16);
	TStyle6.mTopColor		= tonumber("ff274dde", 16);
	TStyle6.mBottomColor	= tonumber("ff274dde", 16);

	TStyle7 = Engine.TextStyle(); -- damage mercenary
	TStyle7.mHeight 		= 0.5;
	TStyle7.mRatio			= 2.5;
	TStyle7.mFontName 		= i3k_db_common.engine.defaultFont;
	TStyle7.mTextColor		= tonumber("00ffffff", 16);
	TStyle7.mTopColor		= tonumber("fff6e1bc", 16);
	TStyle7.mBottomColor	= tonumber("ffe0f7ef", 16);

	TStyle8 = Engine.TextStyle(); -- kungfu
	TStyle8.mHeight 		= 0.5;
	TStyle8.mRatio			= 2.5;
	TStyle8.mFontName 		= i3k_db_common.engine.defaultFont;
	TStyle8.mTextColor		= tonumber("00ffffff", 16);
	TStyle8.mTopColor		= tonumber("ffffff00", 16);
	TStyle8.mBottomColor	= tonumber("ffffff00", 16);

	TStyle9 = Engine.TextStyle(); -- jueji
	TStyle9.mHeight 		= 0.5;
	TStyle9.mRatio			= 2.5;
	TStyle9.mFontName 		= i3k_db_common.engine.defaultFont;
	TStyle9.mTextColor		= tonumber("00ffffff", 16);
	TStyle9.mTopColor		= tonumber("ff00c6ff", 16);
	TStyle9.mBottomColor	= tonumber("ff00c6ff", 16);

	local mnt1 = i3k_db_common.engine.durNumberEffect[1] / 1000;
	local mnt2 = i3k_db_common.engine.durNumberEffect[2] / 1000;
	local mnt3 = 1.5;
	--Anim3DScaleData --调节字体缩放动画
	--AnimCurveTranslationData --调节字体上漂高度
	AnimData1 = Engine.Anim3DScaleData(); --normal damage font size anim
	AnimData1:Create();
	AnimData1:AddKeyFrame(0.0, 			Engine.SVector3(1.5, 1.5, 1.5));
	AnimData1:AddKeyFrame(mnt1 * 3 / 5,	Engine.SVector3(1.8, 1.8, 1.8));
	AnimData1:AddKeyFrame(mnt1,			Engine.SVector3(2.0, 2.0, 2.0));

	AnimData2 = Engine.Anim3DScaleData(); --cirt damage font size anim
	AnimData2:Create();
	AnimData2:AddKeyFrame(0.0,			Engine.SVector3(1.5, 1.5, 1.5));
	AnimData2:AddKeyFrame(mnt1 * 3 / 5,	Engine.SVector3(2.2, 2.2, 2.2));
	AnimData2:AddKeyFrame(mnt1,			Engine.SVector3(2.5, 2.5, 2.5));

	AnimData3 = Engine.Anim3DScaleData(); --not used
	AnimData3:Create();
	AnimData3:AddKeyFrame(0.0,			Engine.SVector3(1.0, 1.0, 1.0));
	AnimData3:AddKeyFrame(mnt1 * 3 / 5,	Engine.SVector3(1.5, 1.5, 1.5));
	AnimData3:AddKeyFrame(mnt1,			Engine.SVector3(1.5, 1.5, 1.5));

	AnimData4 = Engine.AnimCurveTranslationData(); -- normal damage font go up anim
	AnimData4:Create();
	AnimData4:AddKeyFrame(0.0,			eIT_Lerp,	Engine.SVector3(0.0, 0.0, 0.0));
	AnimData4:AddKeyFrame(mnt1 * 2 / 6,	eIT_Lerp,	Engine.SVector3(0.2, 1.4, 0.2));
	AnimData4:AddKeyFrame(mnt1,			eIT_Lerp,	Engine.SVector3(0.7, 1.5, 0.7));

	AnimData5 = Engine.AnimCurveTranslationData(); -- cirt damage font go up anim
	AnimData5:Create();
	AnimData5:AddKeyFrame(0.0,			eIT_Lerp,	Engine.SVector3(0.0, 0.5, 0.0));
	AnimData5:AddKeyFrame(mnt1 * 2 / 6,	eIT_Lerp,	Engine.SVector3(0.2, 1.8, 0.2));
	AnimData5:AddKeyFrame(mnt1,			eIT_Lerp,	Engine.SVector3(0.7, 2.0, 0.7));

	AnimData6 = Engine.AnimCurveTranslationData(); -- not used
	AnimData6:Create();
	AnimData6:AddKeyFrame(0.0,			eIT_Lerp,	Engine.SVector3(0.0, 0.2, 0.0));
	AnimData6:AddKeyFrame(mnt1 * 2 / 5,	eIT_Lerp,	Engine.SVector3(0.0, 1.0, 0.0));
	AnimData6:AddKeyFrame(mnt1,			eIT_Lerp,	Engine.SVector3(0.0, 1.8, 0.0));

	AnimData7 = Engine.Anim3DScaleData(); -- buff name font size anim
	AnimData7:Create();
	AnimData7:AddKeyFrame(0.0,			Engine.SVector3(1.5, 1.5, 1.5));
	AnimData7:AddKeyFrame(mnt2 * 3 / 5,	Engine.SVector3(2.0, 2.0, 2.0));
	AnimData7:AddKeyFrame(mnt2,			Engine.SVector3(2.5, 2.5, 2.5));

	AnimData8 = Engine.AnimCurveTranslationData(); --buff name font go up anim
	AnimData8:Create();
	AnimData8:AddKeyFrame(0.0,			eIT_Lerp,	Engine.SVector3(0.0, 0.0, 0.0));
	AnimData8:AddKeyFrame(mnt2 * 2 / 6,	eIT_Lerp,	Engine.SVector3(-0.2, 1.4, -0.2));
	AnimData8:AddKeyFrame(mnt2,			eIT_Lerp,	Engine.SVector3(-0.7, 1.5, -0.7));

	AnimData9 = Engine.Anim3DScaleData(); -- monster damage font size anim(smaller than normal)
	AnimData9:Create();
	AnimData9:AddKeyFrame(0.0, 			Engine.SVector3(1.2, 1.2, 1.2));
	AnimData9:AddKeyFrame(mnt1 * 3 / 5,	Engine.SVector3(1.7, 1.7, 1.7));
	AnimData9:AddKeyFrame(mnt1,			Engine.SVector3(2.2, 2.2, 2.2));

	AnimData10 = Engine.Anim3DScaleData(); -- monster heal,crit damage font size anim
	AnimData10:Create();
	AnimData10:AddKeyFrame(0.0,			Engine.SVector3(1.4, 1.4, 1.4));
	AnimData10:AddKeyFrame(mnt1 * 3 / 5,Engine.SVector3(1.9, 1.9, 1.9));
	AnimData10:AddKeyFrame(mnt1,		Engine.SVector3(2.4, 2.4, 2.4));

	AnimData11 = Engine.Anim3DScaleData(); -- monster buff font size anim
	AnimData11:Create();
	AnimData11:AddKeyFrame(0.0,			Engine.SVector3(1.5, 1.5, 1.5));
	AnimData11:AddKeyFrame(mnt2 * 3 / 5,Engine.SVector3(2.0, 2.0, 2.0));
	AnimData11:AddKeyFrame(mnt2,		Engine.SVector3(2.5, 2.5, 2.5));

	AnimData12 = Engine.Anim3DScaleData(); -- not used
	AnimData12:Create();
	AnimData12:AddKeyFrame(0.0,			Engine.SVector3(0.8, 0.8, 0.8));
	AnimData12:AddKeyFrame(mnt2 * 3 / 5,Engine.SVector3(1.05, 1.05, 1.05));
	AnimData12:AddKeyFrame(mnt2,		Engine.SVector3(1.1, 1.1, 1.1));

	AnimData13 = Engine.Anim3DScaleData(); -- jueji font size
	AnimData13:Create();
	AnimData13:AddKeyFrame(0.0,			Engine.SVector3(1.5, 1.5, 1.5));
	AnimData13:AddKeyFrame(mnt3/4,		Engine.SVector3(2.8, 2.8, 2.8));
	AnimData13:AddKeyFrame(mnt3,		Engine.SVector3(3.0, 3.0, 3.0));

	AnimData14 = Engine.AnimCurveTranslationData(); --jueji text go up
	AnimData14:Create();
	AnimData14:AddKeyFrame(0,			eIT_Lerp,	Engine.SVector3(0.0, 0.0, 0.0));
	AnimData14:AddKeyFrame(mnt3/5,		eIT_Lerp,	Engine.SVector3(0.0, 2.9, -2.2));
	AnimData14:AddKeyFrame(mnt3,		eIT_Lerp,	Engine.SVector3(0.0, 3.6, -4.0));

	AnimData15 = Engine.Anim3DScaleData(); -- kungfu name font size anim
	AnimData15:Create();
	AnimData15:AddKeyFrame(0.0, 			Engine.SVector3(1.5, 1.5, 1.5));
	AnimData15:AddKeyFrame(mnt1 * 3 / 5,	Engine.SVector3(2.3, 2.3, 2.3));
	AnimData15:AddKeyFrame(mnt1,			Engine.SVector3(2.7, 2.7, 2.7));

	AnimData16 = Engine.AnimCurveTranslationData(); --kungfu name font go up anim
	AnimData16:Create();
	AnimData16:AddKeyFrame(0.0,			eIT_Lerp,	Engine.SVector3(0.0, 0.5, 0.0));
	AnimData16:AddKeyFrame(mnt1 * 2 / 5,	eIT_Lerp,	Engine.SVector3(0.0, 2.2, -1.0));
	AnimData16:AddKeyFrame(mnt1,			eIT_Lerp,	Engine.SVector3(0.0, 2.6, -1.7));

	AnimData17 = Engine.Anim3DScaleData(); --内伤冒字-大小
	AnimData17:Create();
	AnimData17:AddKeyFrame(0.0, 			Engine.SVector3(1.5, 1.5, 1.5));
	AnimData17:AddKeyFrame(mnt1 / 2,		Engine.SVector3(1.7, 1.7, 1.7));
	AnimData17:AddKeyFrame(mnt1,			Engine.SVector3(2.0, 2.0, 2.0));
	AnimData18 = Engine.AnimCurveTranslationData(); -- 内伤冒字-漂浮动画
	AnimData18:Create();
	AnimData18:AddKeyFrame(0.0,				eIT_Lerp,	Engine.SVector3(3.5, 1.5, 0.0));
	AnimData18:AddKeyFrame(mnt1 / 2,		eIT_Lerp,	Engine.SVector3(4.0, 1.5, 0.4));
	AnimData18:AddKeyFrame(mnt1,			eIT_Lerp,	Engine.SVector3(4.5, 1.5, 0.7));
	AnimData19 = Engine.AnimCurveTranslationData(); -- 引发内伤冒字-漂浮动画
	AnimData19:Create();
	AnimData19:AddKeyFrame(0.0,				eIT_Lerp,	Engine.SVector3(3.5, 2.5, 0.0));
	AnimData19:AddKeyFrame(mnt1 / 2,		eIT_Lerp,	Engine.SVector3(4.0, 2.5, 0.4));
	AnimData19:AddKeyFrame(mnt1,			eIT_Lerp,	Engine.SVector3(4.5, 2.5, 0.7));
	TextAnimData1 = Engine.TextColorAnim();
	TextAnimData1:AddAnimData(0.0,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("ff24ef8b", 16), tonumber("ff00c65c", 16)));
	TextAnimData1:AddAnimData(mnt1 / 5,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("c024ef8b", 16), tonumber("ff00c65c", 16)));
	TextAnimData1:AddAnimData(mnt1 / 2,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("8024ef8b", 16), tonumber("ff00c65c", 16)));
	TextAnimData1:AddAnimData(mnt1,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("0024ef8b", 16), tonumber("0000c65c", 16)));

	TextAnimData2 = Engine.TextColorAnim(); -- normal damage font color
	TextAnimData2:AddAnimData(0.0,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("ff011df2", 16), tonumber("ff6fc5f0", 16))); --011df2,6fc5f0
	TextAnimData2:AddAnimData(mnt1 / 5,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("c0011df2", 16), tonumber("ff6fc5f0", 16)));
	TextAnimData2:AddAnimData(mnt1 / 2,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("80011df2", 16), tonumber("ff6fc5f0", 16)));
	TextAnimData2:AddAnimData(mnt1,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("00011df2", 16), tonumber("006fc5f0", 16)));

	TextAnimData3 = Engine.TextColorAnim(); -- monster damge font color and normal crit damage
	TextAnimData3:AddAnimData(0.0,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("ff0000ff", 16), tonumber("ff0000ff", 16)));
	TextAnimData3:AddAnimData(mnt1 / 5,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("c00000ff", 16), tonumber("ff0000ff", 16)));
	TextAnimData3:AddAnimData(mnt1 / 2,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("800000ff", 16), tonumber("ff0000ff", 16)));
	TextAnimData3:AddAnimData(mnt1,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("000000ff", 16), tonumber("000000ff", 16)));

	TextAnimData4 = Engine.TextColorAnim();
	TextAnimData4:AddAnimData(0.0,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("ff8deffd", 16), tonumber("ff3eb5f6", 16)));
	TextAnimData4:AddAnimData(mnt1 / 5,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("c08deffd", 16), tonumber("ff3eb5f6", 16)));
	TextAnimData4:AddAnimData(mnt1 / 2,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("808deffd", 16), tonumber("ff3eb5f6", 16)));
	TextAnimData4:AddAnimData(mnt1,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("008deffd", 16), tonumber("003eb5f6", 16)));

	TextAnimData5 = Engine.TextColorAnim(); -- dodge font color
	TextAnimData5:AddAnimData(0.0,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("ffeb993a", 16), tonumber("ffeb993a", 16)));
	TextAnimData5:AddAnimData(mnt1 / 5,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("c0eb993a", 16), tonumber("ffeb993a", 16)));
	TextAnimData5:AddAnimData(mnt1 / 2,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("80eb993a", 16), tonumber("ffeb993a", 16)));
	TextAnimData5:AddAnimData(mnt1,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("00eb993a", 16), tonumber("00eb993a", 16)));

	TextAnimData6 = Engine.TextColorAnim(); -- not used,same with debuff
	TextAnimData6:AddAnimData(0.0,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("ff274dde", 16), tonumber("ff274dde", 16)));
	TextAnimData6:AddAnimData(mnt1 / 5,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("c0274dde", 16), tonumber("ff274dde", 16)));
	TextAnimData6:AddAnimData(mnt1 / 2,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("80274dde", 16), tonumber("ff274dde", 16)));
	TextAnimData6:AddAnimData(mnt1,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("00274dde", 16), tonumber("00274dde", 16)));

	TextAnimData7 = Engine.TextColorAnim(); -- buff font color
	TextAnimData7:AddAnimData(0.0,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("ffeb993a", 16), tonumber("ffeb993a", 16)));
	TextAnimData7:AddAnimData(mnt2 / 5,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("c0eb993a", 16), tonumber("ffeb993a", 16)));
	TextAnimData7:AddAnimData(mnt2 / 2,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("80eb993a", 16), tonumber("ffeb993a", 16)));
	TextAnimData7:AddAnimData(mnt2,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("00eb993a", 16), tonumber("00eb993a", 16)));

	TextAnimData8 = Engine.TextColorAnim(); -- debuff font color
	TextAnimData8:AddAnimData(0.0,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("ff274dde", 16), tonumber("ff274dde", 16)));
	TextAnimData8:AddAnimData(mnt2 / 5,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("c0274dde", 16), tonumber("ff274dde", 16)));
	TextAnimData8:AddAnimData(mnt2 / 2,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("80274dde", 16), tonumber("ff274dde", 16)));
	TextAnimData8:AddAnimData(mnt2,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("00274dde", 16), tonumber("00274dde", 16)));

	TextAnimData9 = Engine.TextColorAnim(); -- mercen damage
	TextAnimData9:AddAnimData(0.0,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("fff6e1bc", 16), tonumber("ffe0f7ef", 16)));
	TextAnimData9:AddAnimData(mnt2 / 5,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("c0f6e1bc", 16), tonumber("ffe0f7ef", 16)));
	TextAnimData9:AddAnimData(mnt2 / 2,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("80f6e1bc", 16), tonumber("ffe0f7ef", 16)));
	TextAnimData9:AddAnimData(mnt2,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("00ccffcc", 16), tonumber("0066ffcc", 16)));

	TextAnimData10 = Engine.TextColorAnim(); -- kungfu
	TextAnimData10:AddAnimData(0.0,		    Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("ffffff00", 16), tonumber("ffffff00", 16)));
	TextAnimData10:AddAnimData(mnt1 / 5,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("c0ffff00", 16), tonumber("ffffff00", 16)));
	TextAnimData10:AddAnimData(mnt1 / 2,	Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("80ffff00", 16), tonumber("ffffff00", 16)));
	TextAnimData10:AddAnimData(mnt1,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("00ffff00", 16), tonumber("00ffff00", 16)));

	TextAnimData11 = Engine.TextColorAnim(); -- jueji
	TextAnimData11:AddAnimData(0.0,		    Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("ff00c6ff", 16), tonumber("ff00c6ff", 16)));
	TextAnimData11:AddAnimData(mnt3/4,    Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("c000c6ff", 16), tonumber("ff00c6ff", 16)));
	TextAnimData11:AddAnimData(mnt3/8*7,    Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("8000c6ff", 16), tonumber("ff00c6ff", 16)));
	TextAnimData11:AddAnimData(mnt3,		Engine.TextColorAnimData(tonumber("00ffffff", 16), tonumber("0000c6ff", 16), tonumber("0000c6ff", 16)));

	self._t_effects = { };
	--[[
	for k = 1, poolsize do
		table.insert(self._t_effects, i3k_text_effect.new('text_effect' .. k));
	end
	]]

	self._image_pre_cache = Engine.SImageDesc();
	self._image_pre_cache:Load("textures/imgs/buffz.imgs");
	for k, v in pairs(g_i3k_db.i3k_db_image_effect) do
		self._image_pre_cache:AddChar(Engine.UTF82A(k), v.image, v.size.width, v.size.height);
	end

	for k, v in pairs(g_i3k_db.i3k_db_image_effect_dynamic) do
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_jia'),	v.prefix .. '_jia',		v.number_size.width, v.number_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_jian'),	v.prefix .. '_jian',	v.number_size.width, v.number_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_cheng'), v.prefix .. '_cheng',	v.number_size.width, v.number_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_chu'),	v.prefix .. '_chu',		v.number_size.width, v.number_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_zk'),	v.prefix .. '_zk',		v.number_size.width, v.number_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_yk'),	v.prefix .. '_yk',		v.number_size.width, v.number_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_偏斜'),	v.prefix .. '_pianxie', v.text_size.width, v.text_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_吸收'),	v.prefix .. '_xishou',	v.text_size.width, v.text_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_暴击'),	v.prefix .. '_baoji',	v.text_size.width, v.text_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_内伤'),	v.prefix .. '_ns',	v.text_size.width, v.text_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_引发内伤'),	v.prefix .. '_yfns',	v.text_size.width*1.7, v.text_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_天枢武罡'),	v.prefix .. '_tswg',	v.text_size.width*0.548, v.text_size.height);
		self._image_pre_cache:AddChar(Engine.UTF82A(k .. '_天枢星岚'),	v.prefix .. '_tsxl',	v.text_size.width*0.548, v.text_size.height);

		for m = 0, 9 do
			self._image_pre_cache:AddChar(k .. '_' .. m, v.prefix .. '_' .. m, v.number_size.width, v.number_size.height);
		end
	end

	self._i_effects = { };
	for k = 1, poolsize do
		table.insert(self._i_effects, i3k_image_effect.new('image_effect' .. k, self._image_pre_cache));
	end

	g_i3k_camera_shake_effect = i3k_camera_shake_effect.new("MainCamera", 300);
end

function i3k_effect_mgr:Cleanup()
	for k = 1, #self._t_effects do
		local eff = self._t_effects[k];
		if eff and eff._effect then
			eff._effect:ClsStyle();
		end
	end

	for k = 1, #self._i_effects do
		local eff = self._i_effects[k];

		eff:ReleaseRes();
	end

	g_i3k_camera_shake_effect = nil;
end

function i3k_effect_mgr:StopAll()
	for k, v in ipairs(self._t_effects) do
		v:Stop();
	end

	for k, v in ipairs(self._i_effects) do
		v:Stop();
	end
end

function i3k_effect_mgr:SetTextEffect(effType, pos, text, duration)
	if self._t_effects then
		for k, eff in pairs(self._t_effects) do
			if eff:SetText(effType, pos, text, duration) then
				return eff;
			end
		end
	end

	return nil;
end

function i3k_effect_mgr:SetImageEffect(ani, pos, prefix, text, duration)
	for k, eff in ipairs(self._i_effects) do
		if eff:CanUse() then
			if not eff:IsCreatRes() then
				eff:CreateRes();
			end

			eff:UseAni(ani);
			eff:SetText(pos, prefix, text, duration);

			return eff;
		end
	end

	return nil;
end

function i3k_effect_mgr:OnUpdate(dTime)
	if self._t_effects then
		for k, eff in ipairs(self._t_effects) do
			eff:OnUpdate(dTime);
		end
	end

	if self._i_effects then
		for k, eff in ipairs(self._i_effects) do
			if eff:InUse() then
				eff:OnUpdate(dTime);
			end
		end
	end

	if g_i3k_camera_shake_effect then
		g_i3k_camera_shake_effect:OnUpdate(dTime);
	end
end
