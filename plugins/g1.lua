local xml = require 'xml'

function run(msg, matches)
    local num = 3;
    if (tonumber(matches[1]) ~= nil and tonumber(matches[1]) > 0 and tonumber(matches[1]) <= 10) then
        num = tonumber(matches[1])
    end
    b, c, h = http.request("http://g1.globo.com/dynamo/rss2.xml")
    if (c == 200) then
        local data = xml.load(b)
        local output = "";
        for x = 9, (18 + (num-10)), 1 do
            output = output .. data[1][x][1][1] .. "\n" .. data[1][x][2][1] .. "\n\n"
        end
        return output
    else
        return "Error code: " .. c
    end
end

return {
    description = "Pega as X noticias mais recentes do G1. Se X não for informado retorna as 3 mais recentes.",
    usage = "!g1 X",
    patterns = {"^!g1 (.*)$", "^!g1$"}, 
    run = run 
}
