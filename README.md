# data_setup
Populate your ZD account with data

Example Usage:
```
require 'zd_data'
a = ZdData::Account.new("https://awootest.zendesk-staging.com", "awoo@zendesk.com", password)
a.setup_data!
```


`setup_data!` does the following:
```
def setup_data!
  create_orgs_and_users                 #creates 10 orgs and 300 end-users
  create_tickets                        #creates 200 tickets
  create_ticket_fields                  #creates 6 ticket fields
  create_macros                         #creates 20 macros
  create_user_fields                    #creates 4 user fields
  create_groups                         #creates 15 groups
  create_admins                         #creates 2 admins
  create_forum_topic_and_topic_comments #create a forum, topics, and topic comments
end
```

if you want to just create some new tickets - you can just call that method instead of setup_data!
```
require 'zd_data'
a = ZdData::Account.new("https://awootest.zendesk-staging.com", "awoo@zendesk.com", password)
a.create_tickets
```

Future TODOs:

Users should have ability to specify how many of each resource they want to create. 

Example: `a.create_tickets(1000)`
