do

--function get_yt_data (yt_code)
--  local url = BASE_URL..'/videos/'..yt_code..'?v=2&alt=jsonc'
--  local res,code  = http.request(url)
--  if code ~= 200 then return "HTTP ERROR" end
--  local data = json:decode(res).data
--  return data
--end

--function send_youtube_data(data, receiver)
--  local title = data.title
--  local description = data.description
--  local uploader = data.uploader
--  local text = title..' ('..uploader..')\n'..description
--  local image_url = data.thumbnail.hqDefault
--  local cb_extra = {receiver=receiver, url=image_url}
--  send_msg(receiver, text, send_photo_from_url_callback, cb_extra)
--end

local char = string.char
 
local function tail(n, k)
  local u, r=''
  for i=1,k do
    n,r = math.floor(n/0x40), n%0x40
    u = char(r+0x80) .. u
  end
  return u, n
end
 
local function to_utf8(a)
  local n, r, u = tonumber(a)
  if n<0x80 then                        -- 1 byte
    return char(n)
  elseif n<0x800 then                   -- 2 byte
    u, n = tail(n, 1)
    return char(n+0xc0) .. u
  elseif n<0x10000 then                 -- 3 byte
    u, n = tail(n, 2)
    return char(n+0xe0) .. u
  elseif n<0x200000 then                -- 4 byte
    u, n = tail(n, 3)
    return char(n+0xf0) .. u
  elseif n<0x4000000 then               -- 5 byte
    u, n = tail(n, 4)
    return char(n+0xf8) .. u
  else                                  -- 6 byte
    u, n = tail(n, 5)
    return char(n+0xfc) .. u
  end
end

function   get_title(url, receiver)
    local net = require("socket.http")
    net.USERAGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36"
    local res,code  = net.request(url)
    if code == 200 then
        local i, f, title = string.find(res, "<title>(.-)</title>")
--        print ('i=' .. i .. ' f=' .. f)
        desc = string.match(res, '<meta property="og:description" content="(.-)" />')
        img = string.match(res, '<meta property="og:image" content="(.-)" />')
        
        if(desc) then
            send_msg(receiver, string.gsub(desc, "&#(%d+);", to_utf8), ok_cb, false)
        end
        
        if(img) then
            send_photo_from_url(receiver, img)
        end
        
        return string.gsub(title, "&#(%d+);", to_utf8)
    end
end

function run(msg, matches)
  --local yt_code = matches[1]
  --local data = get_yt_data(yt_code)
  local receiver = get_receiver(msg)
  --send_youtube_data(data, receiver)
  local title = get_title(matches[1] , receiver)
  return title
end

return {
  description = "Gets OpenGraph metadata from any URL.", 
  usage = "",
  patterns = {
    "(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))",
  },
  run = run 
}

end
