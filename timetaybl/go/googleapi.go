// Compile command: CGO_ENABLED=0 gomobile bind -target macos -o ../frameworks/GoogleApi.xcframework

package googleapi

import (
	"context"
	"fmt"
	"net/http"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/calendar/v3"
	"google.golang.org/api/option"
)

type GoogleDataLoader struct {
	hasError bool
	client   *http.Client
	service  *calendar.Service
	config   *oauth2.Config
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
		loader.hasError = true

		fmt.Println("Error in exchanging token")
	}

	loader.client = loader.config.Client(context.Background(), token)
	service, err := calendar.NewService(context.Background(), option.WithHTTPClient(loader.client))

	if err != nil {
		loader.hasError = true

		fmt.Println("Error getting Calendar API service")
	}

	loader.service = service
}

func (loader *GoogleDataLoader) GetEvents() string {
	events, err := loader.service.Events.List("primary").SingleEvents(true).TimeMin("2022-08-29T00:00:00Z").TimeMax("2022-09-09T22:00:00Z").OrderBy("startTime").Do()

	if err != nil {
		loader.hasError = true
	}

	json, err := events.MarshalJSON()

	if err != nil {
		loader.hasError = true
	}

	return string(json)
}
