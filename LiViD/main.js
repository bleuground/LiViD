Parse.Cloud.define("AddFriendRequest", function (request, response) {

    var FriendRequest = Parse.Object.extend("FriendsIncoming");

    var FRequest = new FriendRequest();

    var user = request.user;

    var query = new Parse.Query(Parse.User);
    query.equalTo("username", request.params.username);
    query.find({
        success: function (people) {
            if(people.length == 0)
            {
                response.success(-5);
                return;
            }

            var person = people[0];
            FRequest.set("OwnerID", user.id);
            FRequest.set("TargetFriend", person.id);
            FRequest.set("Status", 0);

            var query = new Parse.Query("FriendsIncoming");
            query.equalTo("OwnerID", user.id);
            query.equalTo("TargetFriendID", person.id);
            query.find({
                success: function (results) {

                    if (results.length > 0) {
                        response.success(1);
                        return;
                    }
                    FRequest.save(null, {
                        success: function (Friend) {
                            response.success(2);
                        },
                        error: function (Friend, error) {
                            response.error(3);
                        }
                    });
                    response.error(-2);

                },
                error: function () {
                    response.error(-1);
                }
            });
        }
        ,
        error: function (Friend, error) {
            response.error(-4);
        }

    });


});

Parse.Cloud.define("AcceptFriendRequest", function (request, response) {


    var user = request.user;

    var query = new Parse.Query("FriendsIncoming");
    query.equalTo("OwnerID", user.id);
    query.equalTo("TargetFriendID", request.params.TargetFriendID);
    query.find({
        success: function (results) {

            if (results.length > 0) {

                response.success(1);
                return;
            }
            FRequest.save(null, {
                success: function (Friend) {
                    response.success(2);
                },
                error: function (Friend, error) {
                    response.error(3);
                }
            });
            response.error(-2);

        },
        error: function () {
            response.error(-1);
        }
    });
});




 Parse.Cloud.define("RetrieveFriends", function (request, response) {

 var query = new Parse.Query("FriendsAccepted");
 var results = [];


 query.find().then(function (Friends) {
 for (var i = 0; i < Friends.length; i++) {
 results.push(Friends[i]);
 }

 // success has been moved inside the callback for query.find()
 response.success(results);
 }, function (error) {
 // Make sure to catch any errors, otherwise you may see a "success/error not called" error in Cloud Code.
 response.error("Could not retrieve Posts, error " + error.code + ": " + error.message);
 });

Parse.Cloud.job("deleteOldEntries", function(request, status) {

var UploadedVideoCurrent = Parse.Object.extend("UploadedVideoCurrent");
var query = new Parse.Query(UploadedVideoCurrent);

var day = new Date();
day.setDate(day.getDate()-1);

query.lessThan("createdAt", day);
query.equalTo("bought",true);

    query.find({
            success:function(results) {
                for (var i = 0, len = results.length; i < len; i++) {
                    var result = results[i];
                    result.destroy({});
                    console.log("Destroy: "+result);

                }   
            status.success("Delete successfully.");             
            },
            error: function(error) {
            status.error("Uh oh, something went wrong.");
            console.log("Failed!");         
            }
    })

});
