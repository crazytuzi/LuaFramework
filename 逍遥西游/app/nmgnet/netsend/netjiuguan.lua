local netjiuguan = {}
function netjiuguan.askGetFriend(i_index)
  NetSend({i_i = i_index}, "jiuguan", "P6")
end
return netjiuguan
