local tableMethods = {}

function tableMethods.mergeTables(...)
    local merged = {}
    for _, src in ipairs({...}) do
        if src[1] ~= nil then
            for _, el in ipairs(src) do
                table.insert(merged, el)
            end
        else
            table.insert(merged, src)
        end
    end
    return merged
end

return tableMethods