local SMassWeddingPlayEndRes = class("SMassWeddingPlayEndRes")
SMassWeddingPlayEndRes.TYPEID = 12604961
function SMassWeddingPlayEndRes:ctor()
  self.id = 12604961
end
function SMassWeddingPlayEndRes:marshal(os)
end
function SMassWeddingPlayEndRes:unmarshal(os)
end
function SMassWeddingPlayEndRes:sizepolicy(size)
  return size <= 65535
end
return SMassWeddingPlayEndRes
