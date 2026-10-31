-- From qbnewsjob: lua test/locales.lua [resource root] [kora_lib root]
-- Uses the actual kora_lib locale loader; all resource reads are local and inert.
local resource = (arg[1] or '.'):gsub('/$', '') .. '/'
local library = (arg[2] or '../kora_lib'):gsub('/$', '') .. '/'
local checks = 0
local function eq(actual, expected, why)
    checks = checks + 1
    assert(actual == expected, why .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
end
local phrases = {
    de = '~g~E~w~ - Betreten', es = '[E] - Entrar', fr = '~g~E~w~ - Entrer',
    nl = '~g~E~w~ - Enter', ['pt-br'] = '~g~E~w~ - Entrar',
}
for _, language in ipairs({ 'de', 'es', 'fr', 'nl', 'pt-br' }) do
    for _, hasLegacy in ipairs({ false, true }) do
        local previous, created, options = {}, {}, nil
        local env = {
            Lang = hasLegacy and previous or nil,
            GetConvar = function(_, fallback) return language or fallback end,
            Locale = { new = function(_, settings) options = settings; return created end },
        }
        local translations = assert(loadfile(resource .. 'locales/' .. language .. '.lua', 't', env))()
        eq(type(translations), 'table', language .. ' returns its existing locale table')
        eq(translations.text.enter, phrases[language], language .. ' retains original phrase')
        if language == 'nl' and hasLegacy then
            eq(env.Lang, previous, 'Dutch legacy existing Lang remains unchanged')
            eq(options, nil, 'Dutch legacy existing Lang still skips registration')
        else
            eq(env.Lang, created, language .. ' retains legacy registration')
            eq(options.phrases, translations, language .. ' returns the same registered table')
            eq(options.warnOnMissing, true, language .. ' retains legacy missing-key warnings')
            eq(options.fallbackLang, hasLegacy and previous or nil, language .. ' retains legacy fallback')
        end
    end
end

local packaged = {}
local noop = function() end
local manifest = {
    fx_version = noop, game = noop, lua54 = noop, author = noop, description = noop,
    version = noop, dependency = noop, shared_scripts = noop, client_scripts = noop, server_script = noop,
    files = function(paths) packaged = paths end,
}
assert(loadfile(resource .. 'fxmanifest.lua', 't', manifest))()
local function included(path)
    for _, pattern in ipairs(packaged) do
        pattern = '^' .. pattern:gsub('([^%w/*])', '%%%1'):gsub('%*', '[^/]*') .. '$'
        if path:match(pattern) then return true end
    end
    return false
end
for _, language in ipairs({ 'en', 'de', 'es', 'fr', 'nl', 'pt-br' }) do
    eq(included('locales/' .. language .. '.lua'), true, language .. ' locale is declared for client packaging')
end

local selected, saved, event = 'en', nil, nil
Kora = { locale = {} }
GetConvar = function(name, fallback)
    if name == 'qb_locale' then return selected end
    if name == 'qb_locales' then return 'en,de,es,fr,nl,pt-br' end
    return fallback
end
GetResourceKvpString = function() return nil end
SetResourceKvp = function(key, value) saved = { key, value } end
TriggerEvent = function(name, ...) event = { name, ... } end
GetCurrentResourceName = function() return 'kora_lib' end
GetInvokingResource = function() return 'kora_newsjob' end
LoadResourceFile = function(name, path)
    if name ~= 'kora_newsjob' or not included(path) then return nil end
    local file = io.open(resource .. path, 'rb')
    if not file then return nil end
    local source = file:read('a'); file:close(); return source
end
dofile(library .. 'modules/locales/shared.lua')
dofile(library .. 'modules/locales/client.lua')
eq(Kora.lang('text.enter'), 'Enter', 'English locale remains supported')
for _, language in ipairs({ 'de', 'es', 'fr', 'nl', 'pt-br' }) do
    selected, Kora.locale._language = language, nil
    eq(Kora.lang('text.enter'), phrases[language], language .. ' configured language resolves through actual sandbox')
    eq(Kora.locale.translate('kora_newsjob', 'text.enter'), phrases[language], language .. ' explicit-resource lookup matches')
    selected = 'en'
    eq(Kora.locale.setLanguage(language), true, language .. ' player selection remains supported')
    eq(Kora.lang('text.enter'), phrases[language], language .. ' selected language resolves through actual sandbox')
    eq(saved[1], 'locale', 'selection retains existing KVP key')
    eq(saved[2], language, 'selection persists the existing language code')
    eq(event[1], 'kora_lib:client:localeChanged', 'selection retains existing local event')
    if language == 'fr' or language == 'es' then
        eq(Kora.lang('text.title_breaking_news'), '', language .. ' intentional empty title remains empty')
        eq(Kora.lang('text.bottom_breaking_news'), '', language .. ' intentional empty caption remains empty')
    end
end
selected, Kora.locale._language = 'absent', nil
eq(Kora.lang('text.enter'), 'Enter', 'unshipped language keeps English fallback')
eq(Kora.lang('text.absent'), 'text.absent', 'unshipped key keeps raw-key fallback')
print(('qbnewsjob locales: %d checks passed'):format(checks))
