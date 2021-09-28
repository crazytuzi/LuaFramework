local HeadImgRequest = class("HeadImgRequest")
function HeadImgRequest:ctor()
  self.m_HeadImgPath = device.cachePath .. "xiyou_head_img/"
  os.rmdir(self.m_HeadImgPath)
  os.mkdir(self.m_HeadImgPath)
end
function HeadImgRequest:isExistHeadImg(fileName)
  local filePath = string.format("%s%s", self.m_HeadImgPath, fileName)
  return io.exists(filePath), filePath
end
function HeadImgRequest:DownLoadHeadImg(fileName, fileURL, listener)
  local filePath = string.format("%s%s", self.m_HeadImgPath, fileName)
  self:DownLoadFile(fileURL, filePath, function(status, data, msg)
    if status == 1 then
      if listener then
        listener(true, filePath, fileName)
      end
    elseif status == -1 and listener then
      listener(false, filePath, fileName)
    end
  end)
end
function HeadImgRequest:reqHeadImg(fileName, fileURL, listener, forceDownload)
  if forceDownload ~= true then
    local isExist, filePath = self:isExistHeadImg(fileName)
    if isExist then
      if listener then
        listener(true, filePath, fileName)
      end
      return
    end
  end
  self:DownLoadHeadImg(fileName, fileURL, listener)
end
function HeadImgRequest:DownLoadFile(url, savePath, cblistener)
  print("HeadImgRequest:DownLoadFile------>", url, savePath, cblistener)
  local lastRecordTime = cc.net.SocketTCP.getTime()
  local recordProc = 0
  local isCancel = false
  local handler, request
  local function cancelScheduler()
    if handler then
      scheduler.unscheduleGlobal(handler)
      handler = nil
    end
  end
  handler = scheduler.scheduleGlobal(function()
    local ct = cc.net.SocketTCP.getTime()
    print("ct - local lastRecordTime:", ct, lastRecordTime, ct - lastRecordTime, recordProc)
    if ct - lastRecordTime >= 30 then
      cancelScheduler()
      if request then
        print("--->> request cancel")
        request:cancel()
      end
      isCancel = true
      if cblistener then
        cblistener(-1)
      end
    end
  end, 1)
  function callback(event)
    if isCancel then
      return
    end
    if event.name == "inprogress" or event.name == "progress" then
      local dlnow = event.dlnow
      if dlnow == nil then
        dlnow = event.dltotal
      end
      if cblistener then
        cblistener(0, dlnow)
      end
      if recordProc ~= dlnow then
        recordProc = dlnow
        lastRecordTime = cc.net.SocketTCP.getTime()
      end
    else
      cancelScheduler()
      local ok = event.name == "completed"
      local request = event.request
      if not ok then
        print("DownLoadFile Error:", request:getErrorCode(), request:getErrorMessage())
        if cblistener then
          cblistener(-1, request:getErrorCode(), request:getErrorMessage())
        end
        return
      end
      local code = request:getResponseStatusCode()
      if code ~= 200 then
        print("DownLoadFile Error:", code)
        if cblistener then
          cblistener(-1, code, "")
        end
        return
      end
      request:saveResponseData(savePath)
      if cblistener then
        cblistener(1)
      end
    end
  end
  url = string.gsub(url, "https:", "http:")
  print(string.format([[

requestUserIcon:
url=%s
]], url))
  request = network.createHTTPRequest(callback, url, "GET")
  request:setTimeout(1001)
  request:start()
end
g_HeadImgRequest = HeadImgRequest.new()
