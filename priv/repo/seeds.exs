alias Prequest.Repo
alias Prequest.Manage.{Article, User, Topic}

# prevents from seeding the :test environment
if Mix.env() == :dev do
  %User{
    username: "felipe",
    articles: [
      %Article{
        title: "contributing to prequest",
        cover: "https://prequest.co/coolimage.png",
        source: "https://github.com/felipelincoln/prequest/",
        topics: [
          %Topic{name: "elixir"},
          %Topic{name: "ecto"}
        ]
      },
      %Article{
        title: "learning elixir/OTP at prequest",
        cover: "https://prequest.co/elixirotp.png",
        source: "https://github.com/felipelincoln/blog/",
        topics: [
          %Topic{name: "phoenix"},
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
          cover: "some cover",
          source: "some source#{num}",
          topics: [
            %Topic{name: "el#{num}ixir"},
            %Topic{name: "ec#{num}to"}
          ]
        },
        %Article{
          title: "some other tit#{num}le",
          cover: "some other cover",
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
