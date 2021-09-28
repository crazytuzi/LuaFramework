------------------------------------------------------
module(..., package.seeall)

local require = require

require("logic/battle/i3k_skill_talent_def");

-----------------------------------------------------------------
i3k_skill_talent = i3k_class("i3k_skill_talent");
function i3k_skill_talent:ctor(id, lvl, cfg)
	self._id		= id;
	self._lvl		= lvl;
	self._guid		= i3k_gen_buff_guid();
	self._cfg		= cfg;
	self._hoster	= nil;
	----i3k_log("new skill talent id = " .. id .. ", level = " .. lvl);
end

function i3k_skill_talent:Bind(hoster)
	if self._cfg then
		self._hoster = hoster;

		local cfgs = self._cfg;
		local args = cfgs.args;

		if cfgs.type == eTalent_ChProp then
			----i3k_log("update passive property id = " .. args.pid .. ", value = " .. args.value);

			hoster:AddExtProperty(args.pid, args.vtype, args.value);
		elseif cfgs.type == eTalent_AddAiNode then
			self._tids = { };
			for k, v in ipairs(args.aid) do
				local mgr = hoster._triMgr;
				if mgr then
					local tcfg = i3k_db_ai_trigger[v];
					if tcfg then
						local TRI = require("logic/entity/ai/i3k_trigger");
						local tri = TRI.i3k_ai_trigger.new(hoster);
						if tri:Create(tcfg, -1,v) then
							local tid = mgr:RegTrigger(tri, hoster);
							if tid >= 0 then
								--i3k_log("add ai node id = " .. v .. ", trigger id = " .. tid);

								table.insert(self._tids, tid);
							end
						end
					end
				end
			end
		elseif cfgs.type == eTalent_ChSkill then
			local all_skills, use_skills = g_i3k_game_context:GetRoleSkills();
			local skill = all_skills[args.sid];
			local slotid = 0
			for k,v in pairs(use_skills) do
				if v == args.sid then
					slotid = k;
					break;
				end
			end
			if skill then
				--i3k_log("found skill " .. skill.id .. " level = " .. skill.lvl .. ", realm = " .. skill.state);
				local lvl = skill.lvl
				local longyininfo = g_i3k_game_context:GetLongYinInfo();
				if longyininfo.skills then
					if longyininfo.skills[args.sid] then
						lvl = lvl + longyininfo.skills[args.sid]
					end
				end
				local scfg = i3k_db_skills[skill.id];
				if scfg then
					local _S = require("logic/battle/i3k_skill");
					local _skill = _S.i3k_skill_create(hoster, scfg, lvl, skill.state, skill.eSG_Skill);
					if _skill then
						local bid = _skill:GetBuffIDByIdx(args.buff);

						local bcfg = i3k_db_buff[bid];
						if bcfg then
							local _B = require("logic/battle/i3k_buff");

							local _buff = _B.i3k_buff.new(_skill, bid, bcfg);
							_buff:SetPassive(true);
							_buff:SetValueOdds(args.valueOdds);
							_buff:SetRealmOdds(args.realmOdds);

							if hoster:AddBuff(hoster, _buff) then
								self._buff = _buff;

								--i3k_log("change skill " .. args.sid .. " to passive skill, buff = " .. bid .. ", value odds = " .. args.valueOdds .. ", realm odds = " .. args.realmOdds);
							end
						end
					end
				end
				if slotid ~= 0 then
					local skillids = g_i3k_game_context:GetRolePassiveSkills()
					local findskill = false;
					for k,v in pairs(all_skills) do
						if v.id ~= args.sid then
							findskill = true
						end
						if findskill then
							for k1,v1 in pairs(use_skills) do
								if v1 == v.id then
									findskill = false;
									break;
								end
							end
						end
						if findskill then
							for k1,v1 in pairs(skillids) do
								if v1 == v.id then
									findskill = false;
									break;
								end
							end
						end
						if findskill then
							findskill = not g_i3k_game_context:GetIsNotDrag(v.id)
						end
						if findskill then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(282))
							i3k_sbean.goto_skill_select(slotid, v.id, g_CHANGE_SKILL_PASSIVE);
							break;
						end
					end
				end
			end
		elseif cfgs.type == eTalent_AddBuff then
			local bcfg = i3k_db_buff[args.buff];
			if bcfg then
				local _B = require("logic/battle/i3k_buff");

				local _buff = _B.i3k_buff.new(nil, args.buff, bcfg);
				_buff:SetPassive(true);
				_buff:SetValueOdds(1);
				_buff:SetRealmOdds(1);

				if hoster:AddBuff(hoster, _buff) then
					self._buff = _buff;
					--i3k_log("Talent AddBuff  = " .. args.buff );
				end
			end
		elseif cfgs.type == eTalent_ChangeSkillEx then
			if not hoster._talentChangeSkill[args.skillID] then
				hoster._talentChangeSkill[args.skillID] = {}
			end
			if not hoster._talentChangeSkill[args.skillID][self._id] then
				hoster._talentChangeSkill[args.skillID][self._id] = {}
			end
			info = {eventid = args.eventid,Eventchangetype = args.Eventchangetype,valuetype = args.valuetype,value = args.value}
			table.insert(hoster._talentChangeSkill[args.skillID][self._id],info)
			--i3k_log("add skillEx:"..args.skillID.." from talent:"..self._id)
		elseif cfgs.type == eTalent_ChangeSkillCom then
			if not hoster._talentChangeSkill[args.skillID] then
				hoster._talentChangeSkill[args.skillID] = {}
			end
			if not hoster._talentChangeSkill[args.skillID][self._id] then
				hoster._talentChangeSkill[args.skillID][self._id] = {}
			end
			info = {Commonchangetype = args.Commonchangetype,valuetype = args.valuetype,value =  args.value}
			table.insert(hoster._talentChangeSkill[args.skillID][self._id],info)
			--i3k_log("add skillCommon:"..args.skillID.." from talent:"..self._id)
		elseif cfgs.type == eTalent_ChangeAiEffect then
			if not hoster._talentChangeAi[args.AiID] then
				hoster._talentChangeAi[args.AiID] = {}
			end
			if not hoster._talentChangeAi[args.AiID][self._id] then
				hoster._talentChangeAi[args.AiID][self._id] = {}
			end
			info = {changetype = args.changetype,argpos = args.argpos ,valuetype = args.valuetype,value =  args.value}
			table.insert(hoster._talentChangeAi[args.AiID][self._id],info)
			--i3k_log("Change talentAi:"..args.AiID.." from talent:"..self._id)
		elseif cfgs.type == eTalent_ExtendWeaponDur then--延长神兵持续时间
			hoster:SetWeaponAwakeExtendTicks(args.weaponID, args.time)
		else

		end

		return true;
	end

	return false;
end

function i3k_skill_talent:Unbind()
	local h = self._hoster;

	if h then
		local cfgs = self._cfg;
		local args = cfgs.args;

		if cfgs.type == eTalent_ChProp then
		elseif cfgs.type == eTalent_AddAiNode then
			local mgr = h._triMgr;
			if mgr then
				for k, v in ipairs(self._tids) do
					--i3k_log("remove ai node trigger id = " .. v);

					mgr:UnregTrigger(v);
				end
			end
		elseif cfgs.type == eTalent_ChSkill then
			if self._buff then
				h:RmvBuff(self._buff);

				--i3k_log("change skill " .. args.sid .. " from passive skill, buff = " .. args.buff .. ", value odds = " .. args.valueOdds .. ", realm odds = " .. args.realmOdds);
			end
		elseif cfgs.type == eTalent_AddBuff then
			if self._buff then
				h:RmvBuff(self._buff);
				--i3k_log("Talent RemBuff  = " .. args.buff );
			end
		elseif cfgs.type == eTalent_ChangeSkillEx then
			if h._talentChangeSkill[args.skillID] and h._talentChangeSkill[args.skillID][self._id] then
				h._talentChangeSkill[args.skillID][self._id] = nil
				local count = 0
				for k,v in pairs(h._talentChangeSkill[args.skillID]) do
					count = count + 1;
				end
				if count == 0 then
					h._talentChangeSkill[args.skillID] = nil;
				end
			end
			--i3k_log("remove skillEx:"..args.skillID.." from talent:"..self._id)
		elseif cfgs.type == eTalent_ChangeSkillCom then
			if h._talentChangeSkill[args.skillID] and h._talentChangeSkill[args.skillID][self._id] then
				h._talentChangeSkill[args.skillID][self._id] = nil
				local count = 0
				for k,v in pairs(h._talentChangeSkill[args.skillID]) do
					count = count + 1;
				end
				if count == 0 then
					h._talentChangeSkill[args.skillID] = nil;
				end
			end
			--i3k_log("remove Common:"..args.skillID.." from talent:"..self._id)
		elseif cfgs.type == eTalent_ChangeAiEffect then
			if h._talentChangeAi[args.AiID] and h._talentChangeAi[args.AiID][self._id] then
				h._talentChangeAi[args.AiID][self._id] = nil
				local count = 0
				for k,v in pairs(h._talentChangeAi[args.AiID]) do
					count = count + 1;
				end
				if count == 0 then
					h._talentChangeAi[args.AiID] = nil;
				end
			end
			--i3k_log("remove talentAi:"..args.AiID.." from talent:"..self._id)
		elseif cfgs.type == eTalent_ExtendWeaponDur then
			h:SetWeaponAwakeExtendTicks(args.weaponID, 0)
		else
		end

		return true;
	end

	return false;
end

function i3k_skill_talent:OnUpdate(dTime)
end

function i3k_skill_talent:OnLogic(dTick)
end

