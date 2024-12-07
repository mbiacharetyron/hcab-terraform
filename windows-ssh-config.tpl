add-content -path c:users/lenovo/.ssh/config -value @'

Host $(hostname)
    Hostname $(hostname)
    User $(user)
    IdentityFile $(identityfile)
'@