function scrollAt(){
  let scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
  let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight;
  let clientHeight = document.documentElement.clientHeight;

  return scrollTop / (scrollHeight - clientHeight) * 100;
};

const FeedScroll = {
  id(){ return this.el.dataset.id },
  page(){ return this.el.dataset.page },
  order(){ return this.el.dataset.order },
  query(){ return this.el.dataset.query },
  next(){ return this.el.dataset.next },
  mounted(){
    this.pending = this.page()
    window.addEventListener("scroll", e => {
      if(this.next() == "true" && this.pending == this.page() && scrollAt() > 90){
        this.pending = this.page() + 1;
        let params = {
          page: this.page(),
          order: this.order(),
          query: this.query(),
        };

        // Calling "load" event.
        console.log(`component ${this.id()} js hook`);
        this.pushEventTo(`#${this.id()}`, "load", params);
      }
    })
  },
  reconnected(){ this.pending = this.page() },
  updated(){ this.pending = this.page() }
};

export default FeedScroll;
