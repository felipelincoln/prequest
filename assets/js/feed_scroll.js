function scrollAt(){
  let scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
  let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight;
  let clientHeight = document.documentElement.clientHeight;

  return scrollTop / (scrollHeight - clientHeight) * 100;
};

const FeedScroll = {
  id(){ return this.el.dataset.id },
  page(){ return this.el.dataset.page },
  next(){ return this.el.dataset.next },
  mounted(){
    this.pending = this.page()
    window.addEventListener("scroll", e => {
      if(this.next() == "true" && this.pending == this.page() && scrollAt() > 90){
        this.pending = this.page() + 1;

        // Calling "load" event.
        console.log(`component ${this.id()} js hook`);
        this.pushEventTo(`#${this.id()}`, "load", {page: this.page()});
      }
    })
  },
  reconnected(){ this.pending = this.page() },
  updated(){ this.pending = this.page() }
};

export default FeedScroll;
