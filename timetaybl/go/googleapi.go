// Compile command: CGO_ENABLED=0 gomobile bind -target macos -o ../frameworks/GoogleApi.xcframework

package googleapi

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/calendar/v3"
	"google.golang.org/api/option"
)

type GoogleDataLoader struct {
	authenticated bool
	client        *http.Client
	service       *calendar.Service
	config        *oauth2.Config
}

func NewDataLoader(credentials string) *GoogleDataLoader {
	var config, err = google.ConfigFromJSON([]byte(credentials), calendar.CalendarReadonlyScope)

	if err != nil {
		fmt.Println("Error in generating config")
	}

	return &GoogleDataLoader{false, &http.Client{}, &calendar.Service{}, config}
}

func (loader *GoogleDataLoader) GetAuthURLstring() string {
	return loader.config.AuthCodeURL("state-token", oauth2.AccessTypeOffline)
}

func (loader *GoogleDataLoader) GetClient(authCode string) {
	var token, err = loader.config.Exchange(context.TODO(), authCode)

	if err != nil {
		fmt.Println("Error in exchanging token")
	}

	loader.client = loader.config.Client(context.Background(), token)
	service, err := calendar.NewService(context.Background(), option.WithHTTPClient(loader.client))

	if err != nil {
		fmt.Println("Error getting Calendar API service")

		loader.authenticated = true
	}

	loader.service = service
}

func (loader *GoogleDataLoader) GetEvents() string {
	t := time.Now().Format(time.RFC3339)

	events, _ := loader.service.Events.List("primary").SingleEvents(true).TimeMin(t).OrderBy("startTime").Do()

	json, _ := events.MarshalJSON()

	return string(json)
}
