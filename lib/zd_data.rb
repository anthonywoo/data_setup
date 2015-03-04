require 'faraday'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'json'
require 'active_support/core_ext/hash'

module ZdData
  class Account

    def initialize(url, user, pass, concurrency = 5)
      manager = Typhoeus::Hydra.new(max_concurrency: concurrency)
      @connection = Faraday.new(:url => url, :parallel_manager => manager) do |builder|
        builder.adapter :typhoeus
      end

      @connection.basic_auth(user, pass)
    end

    def post(endpoint, data)
      @connection.post do |req|
        req.url "#{endpoint}.json"
        req.headers["Content-Type"] = 'application/json'
        req.body = data
      end
    end

    def multi_post(count, endpoint, key, data = {}) #returns ids
      responses = []

      @connection.in_parallel do
        count.times do |i|
          json_data = default_data.deep_merge(data).to_json
          responses << post(endpoint, json_data)
        end
      end

      responses.select! { |response| response.status == 201 }

      responses.map! do |response|
        return_id(response, key)
      end
    end

    def setup_data!
      create_orgs_and_users                 #creates 10 orgs and 300 end-users
      create_tickets                        #creates 200 tickets
      create_ticket_fields                  #creates 6 ticket fields
      create_macros                         #creates 20 macros
      create_user_fields                    #creates 4 user fields
      create_groups                         #creates 15 groups
      create_admins
      create_forum_topic_and_topic_comments #create a forum, topics, and topic comments
      puts "data setup complete"
    end

    def create_forum_topic_and_topic_comments
      puts "creating a forum"
      self.class.send(:define_method, :default_data, lambda {{"forum" => {"name" => "ZdForum#{rand(10000000)}", "access" => "everybody", "locked" => false}}})
      forum = multi_post(1, "api/v2/forums", "forum")

      puts "creating 10 topics"
      self.class.send(:define_method, :default_data, lambda {{"topic" => {"title" => "ZdTopic#{rand(10000000)}", "body" => "stuff", "forum_id" => forum[0]}}})
      topics = multi_post(10, "api/v2/topics", "topic")

      puts "creating 15 topic comments"
      self.class.send(:define_method, :default_data, lambda {{"topic_comment" => {"body" => "ZdComment#{rand(1000000)}"}}})
      multi_post(15, "api/v2/topics/#{topics[0]}/comments", "topic_comment")
    end

    def create_groups
      puts "creating 15 groups"
      self.class.send(:define_method, :default_data, lambda {{"group" => {"name" => "ZdGroup #{rand(10000000)}"}}})
      multi_post(15, "api/v2/groups", "group")
    end

    def create_user_fields
      puts "creating some user fields"
      self.class.send(:define_method, :default_data, lambda {{"user_field" => {"type" => "text", "title" => "Age #{rand(10000000)}", "key" => "age_#{rand(10000000)}"}}})
      multi_post(2, "api/v2/user_fields", "user_field")

      self.class.send(:define_method, :default_data, lambda {{"user_field" => {"type" => "checkbox", "title" => "Yes #{rand(10000000)}", "key" => "yes_#{rand(10000000)}"}}})
      multi_post(2, "api/v2/user_fields", "user_field")
    end

    def create_macros
      puts "creating 20 macros"
      self.class.send(:define_method, :default_data, lambda {{"macro" => {
        "title" => "Zd Low Priority #{rand(10000000)}",
        "actions" => ["field" => "priority", "value" => "low"]
      }}})

      multi_post(20, "api/v2/macros", "macro")
    end

    def create_orgs_and_users
      self.class.send(:define_method, :default_data, lambda {{"organization" => {"name" => "ZdOrg #{rand(10000000)}"}}})
      puts "creating 10 orgs"
      orgs = multi_post(10, "/api/v2/organizations", "organization")

      puts "creating 100 users in three of those orgs"
      orgs[0..2].each do |org_id|
        self.class.send(:define_method, :default_data, lambda {{"user" => {"name" => "ZdUser #{rand(10000000)}", "organization_id" => org_id}}})
        multi_post(100, "/api/v2/users", "user")
      end
    end

    def create_ticket_fields
      puts "creating some ticket fields"
      self.class.send(:define_method, :default_data, lambda {{"ticket_field" => {"type" => "text", "title" => "Age #{rand(10000000)}"}}})
      multi_post(2, "api/v2/ticket_fields", "ticket_field")

      self.class.send(:define_method, :default_data, lambda {{"ticket_field" => {"type" => "checkbox", "title" => "Yes #{rand(10000000)}"}}})
      multi_post(2, "api/v2/ticket_fields", "ticket_field")


      self.class.send(:define_method, :default_data, lambda {{"ticket_field" => {
        "type" => "tagger", 
        "title" => "Dropdown #{rand(10000000)}",
        "custom_field_options" => [
          {"name"=>"name1", "value"=>"val11#{rand(10000000)}"},
          {"name"=>"name2", "value"=>"val22#{rand(10000000)}"}
        ]}
      }})
      multi_post(2, "api/v2/ticket_fields", "ticket_field")
    end

    def create_tickets
      puts "creating 200 tickets"
      self.class.send(:define_method, :default_data, lambda {{"ticket" => {"subject" => "Zd Ticket #{rand(10000000)}", "comment" => { "body" => "first comment"}}}})
      tickets = multi_post(200, "/api/v2/tickets", "ticket")
    end

    def return_id(response, key)
      JSON.parse(response.body)[key]["id"]
    end

    def create_admins
      puts "creating 2 admins"
      self.class.send(:define_method, :default_data, lambda {{"user" => {"name" => "autouser#{rand(10000000)}", "email" => "autoemail#{rand(1000000)}@zzz.zz", "role" => "admin"}}})
      tickets = multi_post(2, "/api/v2/users", "user")
    end

    def default_data
      {}
    end
    
  end
end
