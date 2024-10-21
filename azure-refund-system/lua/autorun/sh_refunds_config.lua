AzureRefunds = AzureRefunds or {}

-- Whick ranks have access to the menu?
AzureRefunds.Access = {
    ["superadmin"] = true,
    ["admin"] = true
}

-- Which ranks can bypass the max refunds limit?
AzureRefunds.Bypass = {
    ["superadmin"] = true
}

-- Which weapons cannot be given?
AzureRefunds.Blacklist = {
    ["arrest_stick"] = true
}