searchNodes=[{"doc":"A public API for managing content.","ref":"Prequest.CMS.html","title":"Prequest.CMS","type":"module"},{"doc":"Creates an article.Examplesiex&gt; create_article(%{ ...&gt; title: &quot;some title&quot;, ...&gt; source: &quot;some github url&quot;, ...&gt; cover: &quot;some image url&quot;, ...&gt; user_id: 10 ...&gt; }) {:ok, %Article{}} iex&gt; create_article(%{}) {:error, %Ecto.Changeset{}}A topics key can be passed in the map input to associate topics with the article, whether it already exists or not.iex&gt; create_article(%{ ...&gt; title: &quot;some title2&quot;, ...&gt; source: &quot;some github url2&quot;, ...&gt; cover: &quot;some image url2&quot;, ...&gt; user_id: 10, ...&gt; topics: [%{name: &quot;elixir&quot;}, %{name: &quot;phoenix&quot;}] ...&gt; }) {:ok, %Article{}}Once the topics named &quot;elixir&quot; and &quot;phoenix&quot; was created in the previous example, we can associate them again with a new article. We can proceed in two manners:Get its struct from database and insert it into the topics list.Pass the same map we used to create it.Let's use the &quot;phoenix&quot; topic in the former way and &quot;elixir&quot; in the latter.iex&gt; topic = CMS.get_topic(&quot;phoenix&quot;) iex&gt; create_article(%{ ...&gt; title: &quot;some title3&quot;, ...&gt; source: &quot;some github url3&quot;, ...&gt; cover: &quot;some image url3&quot;, ...&gt; user_id: 10, ...&gt; topics: [%{name: &quot;elixir&quot;}, topic] ...&gt; }) {:ok, %Article{}}","ref":"Prequest.CMS.html#create_article/1","title":"Prequest.CMS.create_article/1","type":"function"},{"doc":"Creates a report.Examplesiex&gt; create_report(%{user_id: 15, article_id: 3}) {:ok, %Report{}} iex&gt; create_report(%{}) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#create_report/1","title":"Prequest.CMS.create_report/1","type":"function"},{"doc":"Creates a topic.Examplesiex&gt; create_topic(%{name: &quot;new topic&quot;}) {:ok, %Topic{}} iex&gt; create_topic(%{name: &quot;&quot;}) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#create_topic/1","title":"Prequest.CMS.create_topic/1","type":"function"},{"doc":"Creates a user.Examplesiex&gt; create_user(%{ username: &quot;felipelincoln&quot;, name: &quot;Felipe de Souza Lincoln&quot;, bio: &quot;this is my bio&quot; }) {:ok, %User{}} iex&gt; create_user(%{}) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#create_user/1","title":"Prequest.CMS.create_user/1","type":"function"},{"doc":"Creates a view.Examplesiex&gt; create_view(%{user_id: 23, article_id: 12}) {:ok, %View{}} iex&gt; create_view(%{}) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#create_view/1","title":"Prequest.CMS.create_view/1","type":"function"},{"doc":"Deletes an article.Examplesiex&gt; delete_article(article) {:ok, %Article{}} iex&gt; delete_article(article) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#delete_article/1","title":"Prequest.CMS.delete_article/1","type":"function"},{"doc":"Deletes a report.Examplesiex&gt; delete_report(report) {:ok, %Report{}} iex&gt; delete_report(report) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#delete_report/1","title":"Prequest.CMS.delete_report/1","type":"function"},{"doc":"Deletes a topic.Examplesiex&gt; delete_topic(topic) {:ok, %Topic{}} iex&gt; delete_topic(topic) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#delete_topic/1","title":"Prequest.CMS.delete_topic/1","type":"function"},{"doc":"Deletes a user.Examplesiex&gt; delete_user(user) {:ok, %User{}} iex&gt; delete_user(user) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#delete_user/1","title":"Prequest.CMS.delete_user/1","type":"function"},{"doc":"Deletes a view.Examplesiex&gt; delete_view(view) {:ok, %View{}} iex&gt; delete_view(view) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#delete_view/1","title":"Prequest.CMS.delete_view/1","type":"function"},{"doc":"Gets a single article.Raises Ecto.NoResultsError if the Article does not exist.Examplesiex&gt; get_article!(123) %Article{} iex&gt; get_article!(456) ** (Ecto.NoResultsError)","ref":"Prequest.CMS.html#get_article!/1","title":"Prequest.CMS.get_article!/1","type":"function"},{"doc":"Gets a single report.Raises Ecto.NoResultsError if the Report does not exist.Examplesiex&gt; get_report!(123) %Report{} iex&gt; get_report!(456) ** (Ecto.NoResultsError)","ref":"Prequest.CMS.html#get_report!/1","title":"Prequest.CMS.get_report!/1","type":"function"},{"doc":"Gets a single topic by its name.Examplesiex&gt; get_topic(&quot;elixir&quot;) %Topic{} iex&gt; get_topic(&quot;&quot;) nil","ref":"Prequest.CMS.html#get_topic/1","title":"Prequest.CMS.get_topic/1","type":"function"},{"doc":"Gets a single user by its username.Examplesiex&gt; get_user(&quot;felipelincoln&quot;) %User{} iex&gt; get_user(&quot;nonexistinguser&quot;) nil","ref":"Prequest.CMS.html#get_user/1","title":"Prequest.CMS.get_user/1","type":"function"},{"doc":"Gets a single user.Raises Ecto.NoResultsError if the User does not exist.Examplesiex&gt; get_user!(123) %User{} iex&gt; get_user!(456) ** (Ecto.NoResultsError)","ref":"Prequest.CMS.html#get_user!/1","title":"Prequest.CMS.get_user!/1","type":"function"},{"doc":"Gets a single view.Examplesiex&gt; get_view(user.id, article.id) %View{} iex&gt; get_view(0, 0) nil","ref":"Prequest.CMS.html#get_view/2","title":"Prequest.CMS.get_view/2","type":"function"},{"doc":"Preload all fields from a schema's struct inside a pipeline.ExamplesIt can be used for create_* pipelines,iex&gt; create_article(%{...}) {:ok, %Article{ #=&gt; reports: #Ecto.Association.NotLoaded&lt;association :reports is not loaded&gt; #=&gt; user: #Ecto.Association.NotLoaded&lt;association :user is not loaded&gt; #=&gt; views: #Ecto.Association.NotLoaded&lt;association :views is not loaded&gt; ... } } iex&gt; create_article(%{...}) |&gt; preload() {:ok, %Article{ reports: [%Report{}, ...], topics: [%Topic{}, ...], user: %User{}, views: [%View{}, ...], ... } }and also update_* pipelines.iex&gt; update_report(%{...}) {:ok, %Report{ #=&gt; user: #Ecto.Association.NotLoaded&lt;association :user is not loaded&gt; #=&gt; article: #Ecto.Association.NotLoaded&lt;association :article is not loaded&gt; ... } } iex&gt; update_report(%{...}) |&gt; preload() {:ok, %Report{ user: %User{}, article: %Article{}, ... } }If the preceding changeset contain errors it does not do anything.iex&gt; create_topic(%{name: nil}) |&gt; preload() {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#preload/1","title":"Prequest.CMS.preload/1","type":"function"},{"doc":"Preload fields from a schema's struct.Raises ArgumentError if the fields does not exist in the struct.Examplesiex&gt; user %User{} #=&gt; articles: #Ecto.Association.NotLoaded&lt;association :articles is not loaded&gt; iex&gt; preload!(user, :articles) %User{ articles: [%Article{}, ...], ... } iex&gt; article %Article{ #=&gt; reports: #Ecto.Association.NotLoaded&lt;association :reports is not loaded&gt; #=&gt; views: #Ecto.Association.NotLoaded&lt;association :views is not loaded&gt; } iex&gt; preload!(article, [:views, :reports]) %Article{ views: [%View{}, ...], reports: [%Report{}, ...], ... } iex&gt; preload!(article, :field) ** (ArgumentError)","ref":"Prequest.CMS.html#preload!/2","title":"Prequest.CMS.preload!/2","type":"function"},{"doc":"Updates an article.Examplesiex&gt; update_article(article, %{title: &quot;updated title&quot;}) {:ok, %Article{}} iex&gt; update_article(article, %{source: nil}) {:error, %Ecto.Changeset{}}When updating the topics do not forget to append the new one to the existing ones. Otherwise it will be replaced.To see how the topics field works take a look at create_article/1iex&gt; article |&gt; CMS.preload!(:topics) %Article{ topics: [ %Topic{name: &quot;elixir&quot;}, %Topic{name: &quot;ecto&quot;} ], ... } iex&gt; {:ok, article} = update_article(article, %{topics: [%{name: &quot;phoenix&quot;}]}) {:ok, %Article{ topics: [%Topic{name: &quot;phoenix&quot;}], ... } } iex&gt; update_article(article, %{topics: article.topics ++ [%{name: &quot;elixir&quot;}, %{name: &quot;ecto&quot;}]}) {:ok, %Article{ topics: [ %Topic{name: &quot;elixir&quot;}, %Topic{name: &quot;ecto&quot;}, %Topic{name: &quot;phoenix&quot;} ], ... } }","ref":"Prequest.CMS.html#update_article/2","title":"Prequest.CMS.update_article/2","type":"function"},{"doc":"Updates a report.Examplesiex&gt; update_report(report, %{message: &quot;updated message&quot;}) {:ok, %Report{}} iex&gt; update_report(report, %{article_id: nil}) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#update_report/2","title":"Prequest.CMS.update_report/2","type":"function"},{"doc":"Updates a topic.Examplesiex&gt; update_topic(topic, %{name: &quot;updated name&quot;}) {:ok, %Topic{}} iex&gt; update_topic(topic, %{name: &quot;&quot;}) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#update_topic/2","title":"Prequest.CMS.update_topic/2","type":"function"},{"doc":"Updates a user.Examplesiex&gt; update_user(user, %{bio: &quot;updated bio&quot;}) {:ok, %User{}} iex&gt; update_user(user, %{username: nil}) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#update_user/2","title":"Prequest.CMS.update_user/2","type":"function"},{"doc":"Updates a view.Examplesiex&gt; update_view(view, %{liked?: true}) {:ok, %View{}} iex&gt; update_view(view, %{article_id: nil}) {:error, %Ecto.Changeset{}}","ref":"Prequest.CMS.html#update_view/2","title":"Prequest.CMS.update_view/2","type":"function"},{"doc":"","ref":"Prequest.CMS.html#t:article/0","title":"Prequest.CMS.article/0","type":"type"},{"doc":"","ref":"Prequest.CMS.html#t:changeset/0","title":"Prequest.CMS.changeset/0","type":"type"},{"doc":"","ref":"Prequest.CMS.html#t:report/0","title":"Prequest.CMS.report/0","type":"type"},{"doc":"","ref":"Prequest.CMS.html#t:topic/0","title":"Prequest.CMS.topic/0","type":"type"},{"doc":"","ref":"Prequest.CMS.html#t:user/0","title":"Prequest.CMS.user/0","type":"type"},{"doc":"","ref":"Prequest.CMS.html#t:view/0","title":"Prequest.CMS.view/0","type":"type"},{"doc":"CRUD implementation","ref":"Prequest.CMS.CRUD.html","title":"Prequest.CMS.CRUD","type":"behaviour"},{"doc":"","ref":"Prequest.CMS.CRUD.html#c:create/1","title":"Prequest.CMS.CRUD.create/1","type":"callback"},{"doc":"","ref":"Prequest.CMS.CRUD.html#c:delete/1","title":"Prequest.CMS.CRUD.delete/1","type":"callback"},{"doc":"","ref":"Prequest.CMS.CRUD.html#c:read!/1","title":"Prequest.CMS.CRUD.read!/1","type":"callback"},{"doc":"","ref":"Prequest.CMS.CRUD.html#c:update/2","title":"Prequest.CMS.CRUD.update/2","type":"callback"},{"doc":"","ref":"Prequest.CMS.CRUD.html#t:changeset/0","title":"Prequest.CMS.CRUD.changeset/0","type":"type"},{"doc":"Contributing to PrequestMake sure to have docker-compose installed.","ref":"contributing.html","title":"Contributing to Prequest","type":"extras"},{"doc":"Enter the development container:git clone https://github.com/felipelincoln/prequest.git cd prequest/ docker-compose run --service-ports web /bin/shCreate the database, run migrations and start the server:mix ecto.setup mix phx.serverAfter exiting the container (with the exit command) you can get back to it:docker start -a -i prequest_web_run_&lt;hash&gt; Alternatively, you can fast start the services:docker-compose up","ref":"contributing.html#running-the-application-locally","title":"Contributing to Prequest - Running the application locally","type":"extras"},{"doc":"Good practice to run before making commits. It will mirror our GitHub action.Run the following inside the container:mix ciThis will run: mix format --check-formatted --dry-run mix credo --strict mix sobelow -v mix coveralls.github","ref":"contributing.html#test-pipeline","title":"Contributing to Prequest - Test pipeline","type":"extras"},{"doc":"Run whenever your changes may cause documentation changes.Run the following inside the container:mix docs","ref":"contributing.html#building-documentation","title":"Contributing to Prequest - Building documentation","type":"extras"}]