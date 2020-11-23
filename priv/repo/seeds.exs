alias Prequest.Repo
alias Prequest.Manage.{Article, User, Topic}

# prevents from seeding the :test environment
if Mix.env() == :dev do
  %User{
    username: "felipe",
    articles: [
      %Article{
        title: "contributing to prequest",
        subtitle: "subcontributing to prequest",
        cover: "https://picsum.photos/id/1001/300/300",
        source: "https://github.com/felipelincoln/prequest/",
        topics: [
          %Topic{name: "3elixir"},
          %Topic{name: "ecto"}
        ]
      },
      %Article{
        title: "learning elixir/OTP at prequest",
        subtitle: "subcontributing to prequest",
        cover: "https://picsum.photos/id/7001/300/300",
        source: "https://github.com/felipelincoln/blog/",
        topics: [
          %Topic{name: "3phoenix"},
          %Topic{name: "otp"}
        ]
      }
    ]
  }
  |> Repo.insert!()

  for num <- 1..50 do
    %User{
      username: "felipelincoln#{num}",
      articles: [
        %Article{
          title: "so#{num}me title",
          subtitle: "subcontributing to prequest",
          cover: "https://picsum.photos/id/#{19*num}/300/300",
          source: "some source#{num}",
          topics: [
            %Topic{name: "el#{num}ixir"},
            %Topic{name: "ec#{num}to"}
          ]
        },
        %Article{
          title: "some other tit#{num}le",
          subtitle: "subcontributing to prequest",
          cover: "https://picsum.photos/id/#{18*num}/300/300",
          source: "some #{num}other source",
          topics: [
            %Topic{name: "ph#{num}oenix"}
          ]
        }
      ]
    }
    |> Repo.insert!()
  end
end
