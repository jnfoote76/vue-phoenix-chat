<template>
  <div class="my-app">
    <div class="user-details" v-if="enterName">
      <h1>Vuechat</h1>
      <label>Please select your room and enter your name:</label><br>
      <label>Room: </label>
      <select v-model="selectedRoom">
        <option v-for="room in rooms" :value="room.id">{{room.name}}</option>
        <option disabled>-----------</option>
        <option :value="-1">Create New</option>
      </select>
      <span v-if="selectedRoom === -1">
        <label>Room Name: </label>
        <input type="text" v-model="newRoomName">
      </span>
      <label>Name: </label>
      <input type="text" v-model="username">
      <button v-on:click="submitConnectForm">Next</button>
      <div v-if="errorSubmitting"><strong>{{error}}</strong></div>
    </div>
    <div id="main-container" v-else>
      <users-list/>
      <messages-list/>
      <div id="your-message">
        <input type="text" placeholder="What do you have to say?" v-model="message" v-on:keyup.13="sendMessage">
      </div>
    </div>
  </div>
</template>

<script>
import {Socket, Presence} from "phoenix"
import UsersList from "./users-list"
import MessagesList from "./messages-list"

export default {
  created() {
    this.getRooms()
  },
  data() {
    return {
      socket: null,
      channel: null,
      message: "",
      selectedRoom: -1,
      newRoomName: "",
      username: "",
      enterName: true,
      rooms: [],
    }
  },
  components: {
    'users-list': UsersList,
    'messages-list': MessagesList
  },
  methods: {
    getRooms() {
      // GET /someUrl
      this.$http.get('/api/rooms').then(response => {

        // get body data
        this.rooms = response.body.data;
        console.log("Got rooms!")
        console.log(response)

        }, response => {
          console.log("Uh oh!")
      });
    },
    sendMessage() {
      this.channel.push("new_msg", { body: this.message })
      this.message = ''
    },
    submitConnectForm() {
      if(this.selectedRoom === -1) {
        this.$http.post('/api/rooms', {room: {name: this.newRoomName}}).then(response => {

          // get body data
          console.log("Added new room!")
          console.log(response.body.data)
          console.log(response.body.data.id)
          this.connectToChat(response.body.data.id)
          }, response => {
            this.error = response.body.errors[0]
            console.log(response.body.errors)
        });
      } else {
        this.connectToChat(this.selectedRoom)
      }
    },
    connectToChat(id) {
      let presences = {}
      this.enterName = false
      this.socket = new Socket("/socket", {params: {username: this.username}}),
      this.socket.connect()

      this.channel = this.socket.channel("rooms:" + id, {});
      this.channel.on("new_msg", payload => {
        this.$store.commit('addMessage', { payload });
      });

      this.channel.on("presence_state", state => {
        presences = Presence.syncState(presences, state)
        this.assignUsers(presences)
      })

      this.channel.on("presence_diff", diff => {
        presences = Presence.syncDiff(presences, diff)
        this.assignUsers(presences)
      })

      this.channel.join()
        .receive("ok", response => {
          console.log("Joined successfully", response)
          console.log("Length of response: " + response.messages.length)
          for(var i = 0; i < response.messages.length; i++) {
            let currMessage = response.messages[i]
            console.log("username: " + currMessage.username)
            console.log("body: " + currMessage.body)
            console.log("inserted_at: " + currMessage.inserted_at)
            this.$store.commit('addMessage', {
              payload: {
                body: currMessage.body,
                username: currMessage.username,
                received_at: currMessage.inserted_at,
              }
            })
          }
        })
        .receive("error", response => { console.log("Unable to join", response) })
    },
    assignUsers(presences) {
      let users = Presence.list(presences, (user, {metas: metas}) => {
        return { name: user, online_at: metas[0].online_at }
      })
      this.$store.commit('addUsers', { users })
    }
  }
}
</script>

<style lang="sass">
.my-app {
  h1 {
    text-align: center;
  }

  #main-container {
    position: absolute;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    display: flex;
    overflow: hidden;
  }

  #users-list {
    background-color: #008bdf;
    width: 250px;
    height: 100vh;
    overflow-y: scroll;

    h3 {
      font-size: 0.9em;
      margin-left: 10px;
      color: rgba(255, 255, 255, 0.7);
    }

    ul {
      list-style: none;
      padding-left: 20px;
      color: rgba(255, 255, 255, 0.9);

      li {
        &.user-appear-enter-active, &.user-appear-leave-active {
          transition: all .2s
        }

        &.user-appear-enter, &.user-appear-leave-active {
          opacity: 0;
          transform: translateX(-15px);
        }
      }
    }
  }

  #messages-list {
    padding-top: 20px;
    padding-left: 20px;
    overflow-y: scroll;
    flex: 1;

    ul {
      list-style: none;
      padding: 0;

      li {
        padding: 5px 0;

        &.message-appear-enter-active, &.message-appear-leave-active {
          transition: all .2s
        }

        &.message-appear-enter, &.message-appear-leave-active {
          opacity: 0;
          transform: translateY(20px);
        }

        .message-metadata {
          .username {
            font-weight: bold;
          }

          .received-at {
            color: rgba(0, 0, 0, 0.4);
            margin-left: 5px;
            font-size: 0.9em;
          }
        }
      }
    }
  }

  #your-message {
    position: fixed;
    bottom: 0;
    left: 250px;
    right: 0;
    background: rgba(255, 255, 255, 0.95);
    padding: 15px;

    input {
      width: 100%;
      padding: 5px 8px;
      border-radius: 3px;
      outline: 0;
      border: 1px solid #ddd;
    }
  }
}
</style>
