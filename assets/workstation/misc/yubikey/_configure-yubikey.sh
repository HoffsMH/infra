# assuming you have a reset yubi key via ykman openpgp reset, ykman piv reset
# and ykman oath reset if you know you have the keys or recovery codes needed

# very generally go cached on pin and touch everytime

# this will register the secret keys on the card
# gpg --card-status

# admin(on) > passwd set pins (pins never go in pw vault)
# admin(on) > url
# gpg --edit-card

# disable OTP annoyance from accidently touching card
ykman config usb -d OTP
ykman config usb --no-touch-eject

ykman openpgp set-touch SIG CACHED-FIXED
ykman openpgp set-touch AUT CACHED-FIXED
ykman openpgp set-touch ENC CACHED-FIXED
ykman openpgp set-touch ATT CACHED-FIXED

ykman openpgp set-pin-retries 4 4 4
