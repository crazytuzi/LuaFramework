BackPackBoxLockCDCtr = { };
BackPackBoxLockCDCtr.hasInit = false;
BackPackBoxLockCDCtr.bcd = -1;
BackPackBoxLockCDCtr.enble = false;

--[[
  背包锁  数据管理器

]]

function BackPackBoxLockCDCtr.TryInit()
    if not BackPackBoxLockCDCtr.hasInit then
        BackPackBoxLockCDCtr._sec_timer = Timer.New(BackPackBoxLockCDCtr.SecHander, 1, 999999, false);
        BackPackBoxLockCDCtr._sec_timer:Start();
        BackPackBoxLockCDCtr.hasInit = true;
    end
end 

function BackPackBoxLockCDCtr.StopTimer()
    BackPackBoxLockCDCtr.hasInit = false;
    if (BackPackBoxLockCDCtr._sec_timer) then
        BackPackBoxLockCDCtr._sec_timer:Stop()
        BackPackBoxLockCDCtr._sec_timer = nil
    end
end


function BackPackBoxLockCDCtr.SetDaoJiShiHandler(hd, hd_target)
    BackPackBoxLockCDCtr.hd = hd;
    BackPackBoxLockCDCtr.hd_target = hd_target;
end 

function BackPackBoxLockCDCtr.SecHander()
    local map = GameSceneManager.map;
    if (map == nil or(map and map.info.type ~= InstanceDataManager.MapType.Novice)) then
        local bs = BackpackDataManager._bsize;
        if bs < ProductItem.max_num then
            if BackPackBoxLockCDCtr.bcd > 0 then
                if BackPackBoxLockCDCtr.hd ~= nil then
                    BackPackBoxLockCDCtr.hd(BackPackBoxLockCDCtr.hd_target);
                end
                BackPackBoxLockCDCtr.bcd = BackPackBoxLockCDCtr.bcd - 1;
            elseif BackPackBoxLockCDCtr.bcd == 0 then
                BackpackProxy.UnLockProudctBoxByTime();
                BackPackBoxLockCDCtr.bcd = BackPackBoxLockCDCtr.bcd - 1;
            end
        end
    end
end 

function BackPackBoxLockCDCtr.Set_bcd(v)

    BackPackBoxLockCDCtr.bcd = v;
end