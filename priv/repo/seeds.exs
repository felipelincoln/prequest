alias Prequest.Repo
alias Prequest.Manage.{Article, User, Topic}

# prevents from seeding the :test environment
if Mix.env() == :dev do
  %User{
    username: "felipelincoln",
    articles: [
      %Article{
        title: "some title",
        cover: "some cover",
        source: "some source",
        topics: [
          %Topic{name: "elixir"},
          %Topic{name: "ecto"}
        ]
      },
      %Article{
        title: "some other title",
        cover: "some other cover",
        source: "some other source",
        topics: [
          %Topic{name: "phoenix"}
        ]
      }
    ]
  }
  |> Repo.insert!()
end
