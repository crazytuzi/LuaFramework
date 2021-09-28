local alertTextCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ALERT_TEXT);

MsgUtils = {};


function MsgUtils.GetMsgCfgById(id)
	return ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MESSAGE) [id];
end

function MsgUtils.GetAlertText(id)
	if(alertTextCfg) then
		return alertTextCfg[id]
	end
	return nil;
end

function MsgUtils.ArrayToParam(arr)
	local data = {};
	local index = string.byte("a");
	for i, v in ipairs(arr) do
		data[string.char(index)] = v;
		index = index + 1;
	end
	return data;
end

function MsgUtils.ShowTipsById(id, param)
	local cfg = MsgUtils.GetMsgCfgById(id);
	if cfg then
		MsgUtils.ShowTips(nil, param, cfg.msg);
	end
end

--显示提示.
--label language.lua里配置的标签.
--param 参数
--format 指定的文本格式. 
--msg 指定的文本内容.
function MsgUtils.ShowTips(label, param, format, msg, c)
	local msg = {
		f = format;
		l = label;
		p = param;
		m = msg;
		c = c or "y";
	};
	MessageManager.Dispatch(MessageNotes, MessageNotes.ENV_SHOW_TIPS, msg);
end

function MsgUtils.ShowAlert(id)
	if(id and id > 0) then
		local item = MsgUtils.GetAlertText(id);
		if(item) then
			local msg = {
				t = item.duratime / 1000;
				m = item.content
			};
			MessageManager.Dispatch(MessageNotes, MessageNotes.ENV_SHOW_ALERT, msg);
		end
	end
end

--显示跑马灯
function MsgUtils.ShowMarquee(id, param, content)
	if content == nil then
		local cfg = MsgUtils.GetMsgCfgById(id);
		content = cfg and cfg.msg or id;
	end
	local msg = {
		f = content;
		p = param;
	};
	MessageManager.Dispatch(MessageNotes, MessageNotes.ENV_SHOW_MARQUEE, msg);
end

--显示炫耀公告
function MsgUtils.ShowNotice(id, param)
	local cfg = MsgUtils.GetMsgCfgById(id);
	local msg = {
		f = cfg and cfg.msg or id;
		p = param;
	};
	MessageManager.Dispatch(MessageNotes, MessageNotes.ENV_SHOW_NOTICE, msg);
end

--显示获得物品提示.
function MsgUtils.ShowProps(items,addStrFm)
	local msgs = {};
	for i, v in ipairs(items) do
		msgs[i] = {
			l = addStrFm,
			p = v;
		};
	end
	MessageManager.Dispatch(MessageNotes, MessageNotes.ENV_SHOW_PROPS, msgs);
end

function MsgUtils.ShowTrumpet(id, param)
	local cfg = MsgUtils.GetMsgCfgById(id);
	local msg = {
		f = cfg and cfg.msg or id;
		p = param;
	};
	MessageManager.Dispatch(MessageNotes, MessageNotes.ENV_SHOW_TRUMPET, msg);
end

function MsgUtils.ResetIgnore()
	_ignoreMsgs = {};
end

local _ignoreMsgs = {};
function MsgUtils.GetMsgIsIgnore(msg)
	return _ignoreMsgs[msg] or false;
end

function MsgUtils.SetMsgIsIgnore(msg, v)
	_ignoreMsgs[msg] = v;
end

local notice = LanguageMgr.Get("common/notice")
local agree = LanguageMgr.Get("common/agree")
local cancle = LanguageMgr.Get("common/cancle")
--只能用仙玉
function MsgUtils.UseGoldConfirm(num, target, str, strArg, fun1, fun2, data, yesLbl, noLbl, title, showIngore)
	local sp = nil;
	if strArg == nil then
		sp = {};
	else
		sp = ConfigManager.Clone(strArg);
	end
	sp.num = num;
	
	if(MoneyDataManager.Get_gold() >= sp.num) then		
		local panelNote = ConfirmNotes.OPEN_CONFIRM1PANEL;
		local param = {
			title = title and LanguageMgr.Get(title) or notice,
			msg = LanguageMgr.Get(str, sp),
			ok_Label = yesLbl and LanguageMgr.Get(yesLbl) or agree,
			cance_lLabel = noLbl and LanguageMgr.Get(noLbl) or cancle,
			hander = fun1,
			cancelHandler = fun2,
			target = target;
			data = data
		}

		if showIngore then
			if MsgUtils.GetMsgIsIgnore(str) then
				if target then
					fun1(target, data)
				else
					fun1(data);
				end
				return
			else
				panelNote = ConfirmNotes.OPEN_CONFIRM7PANEL;
				param.toggleHandler = function (v) MsgUtils.SetMsgIsIgnore(str, v) end;
			end
		end

		ModuleManager.SendNotification(panelNote, param);

	else
		ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {			
		msg = LanguageMgr.Get("common/xianyubuzu"),	
		hander = function()
			--ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 3})
            ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});
		end,
		});
	end
end

--优先用绑定 再判断仙域 如果仙域不足会自动弹提示是否充值
function MsgUtils.UseBDGoldConfirm(num, target, str, strArg, fun1, fun2, data, yesLbl, noLbl, title, showIngore)
	local sp = nil;
	if strArg == nil then
		sp = {};
	else
		sp = ConfigManager.Clone(strArg);
	end
	sp.num = num;
	if(MoneyDataManager.Get_gold() + MoneyDataManager.Get_bgold() >= sp.num) then
		local panelNote = ConfirmNotes.OPEN_CONFIRM1PANEL;
		local param = {
			title = title and LanguageMgr.Get(title) or notice,
			msg = LanguageMgr.Get(str, sp),
			ok_Label = yesLbl and LanguageMgr.Get(yesLbl) or agree,
			cance_lLabel = noLbl and LanguageMgr.Get(noLbl) or cancle,
			hander = fun1,
			cancelHandler = fun2,
			target = target;
			data = data
		};

		if showIngore then
			if MsgUtils.GetMsgIsIgnore(str) then
				if target then
					fun1(target, data)
				else
					fun1(data);
				end
				return
			else
				panelNote = ConfirmNotes.OPEN_CONFIRM7PANEL;
				param.toggleHandler = function (v) MsgUtils.SetMsgIsIgnore(str, v) end;
			end
		end

		ModuleManager.SendNotification(panelNote, param);
	else
		ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {			
		msg = LanguageMgr.Get("common/xianyubuzu"),	
		hander = function()
			--ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 3})
            ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});
		end,
		});
	end 
end
--优先用绑定 再判断仙域 如果仙域不足会自动弹提示是否充值,若绑定仙玉足够，则直接调用fun1(target,data)
function MsgUtils.UseBDGoldConfirm2(num, target, str, strArg, fun1, fun2, data, yesLbl, noLbl, title)
	local sp = nil;
	if strArg == nil then
		sp = {};
	else
		sp = ConfigManager.Clone(strArg);
	end
	sp.num = num;
    local bgold = MoneyDataManager.Get_bgold()
    --Warning(bgold .. "_" .. sp.num)
    if(bgold >= sp.num)then
        if fun1 then
            if target then fun1(target, data)
		    else fun1(data) end
        end
        return
    end
	if(MoneyDataManager.Get_gold() + bgold >= sp.num) then
		ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
			title = title and LanguageMgr.Get(title) or notice,
			msg = LanguageMgr.Get(str, sp),
			ok_Label = yesLbl and LanguageMgr.Get(yesLbl) or agree,
			cance_lLabel = noLbl and LanguageMgr.Get(noLbl) or cancle,
			hander = fun1,
			cancelHandler = fun2,
			target = target;
			data = data
		});
	else
		ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {			
		msg = LanguageMgr.Get("common/xianyubuzu"),	
		hander = function()
			--ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 3})
            ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});
		end,
		});
	end 
end

function MsgUtils.ShowConfirm(target, str, strArg, fun1, fun2, data, yesLbl, noLbl, title, showIngore, ok_time, cancel_time, close_time)
	
	local panelNote = ConfirmNotes.OPEN_CONFIRM1PANEL;
	local param = {
		title = title and LanguageMgr.Get(title) or notice,
		msg = LanguageMgr.Get(str, strArg),
		ok_Label = yesLbl and LanguageMgr.Get(yesLbl) or agree,
		cance_lLabel = noLbl and LanguageMgr.Get(noLbl) or cancle,
		hander = fun1,
		cancelHandler = fun2,
		target = target,
		data = data,
		ok_time = ok_time,
		cancel_time = cancel_time,
		close_time = close_time,
	};
	
	if showIngore then
		if MsgUtils.GetMsgIsIgnore(str) then
			if target then
				fun1(target, data)
			else
				fun1(data);
			end
			return
		else
			panelNote = ConfirmNotes.OPEN_CONFIRM7PANEL;
			param.toggleHandler = function (v) MsgUtils.SetMsgIsIgnore(str, v) end;
		end
	end

	ModuleManager.SendNotification(panelNote, param);
end

function MsgUtils.PopPanel(str, strArg, title, txt, target, fun, time)
	ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, {
		title = title and LanguageMgr.Get(title) or notice,
		msg = txt or LanguageMgr.Get(str, strArg),
		target = target;
		hander = fun;
		time = time;
	}
	);	
end

