# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     EventApp.Repo.insert!(%EventApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias EventApp.Repo
alias EventApp.Users.User
alias EventApp.Events.Event

rod = Repo.insert!(%User{name: "rod", email: "rod@test.com"})
pam = Repo.insert!(%User{name: "pam", email: "pam@test.com"})

Repo.insert!(%Event{user_id: rod.id, title: "Rod's Test Event 1", description: "This is a test event 1", date: ~N[2020-03-08 12:00:00]})
Repo.insert!(%Event{user_id: pam.id, title: "Pam's Test Event 1", description: "", date: ~N[2020-03-16 14:00:00]})

Repo.insert!(%Event{user_id: rod.id, title: "Rod's Test Event 2", description: "This is a test event 2", date: ~N[2020-03-10 09:00:00]})
Repo.insert!(%Event{user_id: pam.id, title: "Pam's Test Event 2", description: "", date: ~N[2020-03-20 20:00:00]})

Repo.insert!(%Event{user_id: rod.id, title: "Rod's Test Event 3", description: "This is a test event 3", date: ~N[2020-03-18 10:00:00]})
Repo.insert!(%Event{user_id: pam.id, title: "Pam's Test Event 3", description: "This is a test event", date: ~N[2020-04-21 18:00:00]})