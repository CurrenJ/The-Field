using UnityEngine;
public class SwipeDetector : MonoBehaviour
{
    private Vector2 fingerDown;
    private float fingerDownTime;
    private Vector2 fingerUp;
    private float fingerUpTime;
    public bool detectSwipeOnlyAfterRelease = false;
    public CameraController cameraController;

    public float SWIPE_THRESHOLD = 20f;
    public float TIME_THRESHOLD;

    // Update is called once per frame
    void Update()
    {
        foreach (Touch touch in Input.touches)
        {
            if (touch.phase == TouchPhase.Began)
            {
                fingerUp = touch.position;
                fingerUpTime = Time.time;
                fingerDown = touch.position;
                fingerDownTime = Time.time;
            }

            //Detects Swipe while finger is still moving
            if (touch.phase == TouchPhase.Moved)
            {
                if (!detectSwipeOnlyAfterRelease)
                {
                    fingerDown = touch.position;
                    fingerDownTime = Time.time;
                    checkSwipe();
                }
            }

            //Detects swipe after finger is released
            if (touch.phase == TouchPhase.Ended)
            {
                fingerDown = touch.position;
                fingerDownTime = Time.time;
                checkSwipe();
            }
        }

        if (Input.GetMouseButtonDown(0))
        {
            fingerUp = Input.mousePosition;
            fingerUpTime = Time.time;
            fingerDown = Input.mousePosition;
            fingerDownTime = Time.time;

        }
        if (Input.GetMouseButton(0))
        {
            if (!detectSwipeOnlyAfterRelease)
            {
                fingerDown = Input.mousePosition;
                fingerDownTime = Time.time;
                checkSwipe();
            }
        }
        if (Input.GetMouseButtonUp(0))
        {
            fingerDown = Input.mousePosition;
            fingerDownTime = Time.time;
            checkSwipe();
        }
    }

    void checkSwipe()
    {
        //Check if Vertical swipe
        if (verticalMove() > SWIPE_THRESHOLD && verticalMove() > horizontalValMove() && fingerDownTime - fingerUpTime < TIME_THRESHOLD)
        {
            //Debug.Log("Vertical");
            if (fingerDown.y - fingerUp.y > 0)//up swipe
            {
                OnSwipeUp();
            }
            else if (fingerDown.y - fingerUp.y < 0)//Down swipe
            {
                OnSwipeDown();
            }
            fingerUp = fingerDown;
        }

        //Check if Horizontal swipe
        else if (horizontalValMove() > SWIPE_THRESHOLD && horizontalValMove() > verticalMove() && fingerDownTime - fingerUpTime < TIME_THRESHOLD)
        {
            //Debug.Log("Horizontal");
            if (fingerDown.x - fingerUp.x > 0)//Right swipe
            {
                OnSwipeRight();
            }
            else if (fingerDown.x - fingerUp.x < 0)//Left swipe
            {
                OnSwipeLeft();
            }
            fingerUp = fingerDown;
        }

        //No Movement at-all
        else
        {
            //Debug.Log("No Swipe!");
        }
    }

    float verticalMove()
    {
        return Mathf.Abs(fingerDown.y - fingerUp.y);
    }

    float horizontalValMove()
    {
        return Mathf.Abs(fingerDown.x - fingerUp.x);
    }

    //////////////////////////////////CALLBACK FUNCTIONS/////////////////////////////
    void OnSwipeUp()
    {
    }

    void OnSwipeDown()
    {
    }

    void OnSwipeLeft()
    {
        cameraController.RotateCCW();
    }

    void OnSwipeRight()
    {
        cameraController.RotateCW();
    }
}