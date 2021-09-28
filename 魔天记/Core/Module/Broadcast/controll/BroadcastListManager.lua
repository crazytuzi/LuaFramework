
BroadcastListManager = class("BroadcastListManager");


function BroadcastListManager:New()
    self = { };
    setmetatable(self, { __index = BroadcastListManager });

     self.enterFrameRun = EnterFrameRun:New();

    return self
end

function BroadcastListManager.Get_ins()
   
   if BroadcastListManager.ins ==  nil then
     BroadcastListManager.ins = BroadcastListManager:New();
   end
   return BroadcastListManager.ins;
end


function BroadcastListManager:Crean()
     self.enterFrameRun:Stop();
       self.enterFrameRun:Clean()
end


function BroadcastListManager:AddMsg(str,waitAfterFramer)

      self.enterFrameRun:AddHandler(BroadcastListManager.ShowMsg, self, 1,str);
      self.enterFrameRun:AddHandler(BroadcastListManager.Wait, self, waitAfterFramer);
    
end

function BroadcastListManager:ShowMsg(str)
    MsgUtils.ShowTips(nil, nil, nil, str);
end

function BroadcastListManager:Wait()

end

function BroadcastListManager:Start()
   self.enterFrameRun:Start()
end

function BroadcastListManager:Dispose()
  self.enterFrameRun:Clean()
  self.enterFrameRun:Stop();

   self.enterFrameRun =nil;

end
